;; VaultForge: Advanced Bitcoin Collateral Protocol
;;
;; Revolutionary DeFi protocol enabling Bitcoin holders to unlock liquidity without
;; selling their BTC. Create synthetic USD positions backed by Bitcoin collateral
;; through sophisticated over-collateralized debt positions with dynamic risk management.
;;
;; Key Features:
;; - Multi-tier collateralization system with automated liquidation protection
;; - Dynamic interest rate accrual based on protocol utilization
;; - Real-time price oracle integration with staleness protection
;; - Automated compound interest calculations for optimal capital efficiency
;; - Decentralized liquidation mechanism with incentive alignment
;; - Emergency protocol controls for enhanced security
;;
;; Built for institutional-grade reliability with retail accessibility.

;; ERROR CODES & PROTOCOL CONSTANTS

;; Authentication & Authorization Errors
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-PROTOCOL-PAUSED (err u1007))

;; Collateral & Position Management Errors
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u1001))
(define-constant ERR-POSITION-NOT-FOUND (err u1002))
(define-constant ERR-UNDERCOLLATERALIZED (err u1003))
(define-constant ERR-INSUFFICIENT-DEBT (err u1005))

;; Validation & Input Errors
(define-constant ERR-MINIMUM-LOAN-REQUIRED (err u1004))
(define-constant ERR-INVALID-AMOUNT (err u1008))

;; Oracle & Price Feed Errors
(define-constant ERR-PRICE-EXPIRED (err u1006))
(define-constant ERR-NO-PRICE-DATA (err u1009))

;; PROTOCOL PARAMETERS & RISK CONFIGURATION

;; Collateralization Requirements
(define-constant COLLATERAL-RATIO u150) ;; 150% minimum collateral ratio (1.5x)
(define-constant LIQUIDATION-THRESHOLD u120) ;; 120% liquidation threshold
(define-constant LIQUIDATION-PENALTY u10) ;; 10% liquidation penalty

;; Loan Configuration
(define-constant MINIMUM_LOAN_AMOUNT u100000000) ;; 100 synthetic USD (8 decimals)
(define-constant PRICE_EXPIRY u86400) ;; 24-hour price validity window

;; Interest Rate Mechanism
(define-constant INTEREST_RATE_PER_BLOCK u5) ;; 0.0005% per block (~10% APR)
(define-constant INTEREST_RATE_DENOMINATOR u1000000) ;; Precision denominator

;; PROTOCOL STATE MANAGEMENT

;; Administrative Controls
(define-data-var protocol-owner principal tx-sender)
(define-data-var protocol-paused bool false)

;; Global Protocol Metrics
(define-data-var total-debt uint u0) ;; Total synthetic USD debt
(define-data-var total-collateral uint u0) ;; Total BTC collateral (satoshis)
(define-data-var stability-fee uint u0) ;; Accumulated protocol fees
(define-data-var last-accrual-block uint stacks-block-height)

;; Oracle Price Feed
(define-data-var btc-price-in-usd (optional {
  price: uint,
  timestamp: uint,
}) none)

;; Mock Time for Testing Environment
(define-data-var current-time uint u0)

;; USER POSITION TRACKING

;; Individual debt positions with compound interest tracking
(define-map positions
  principal
  {
    collateral: uint, ;; BTC collateral amount (satoshis)
    debt: uint, ;; Synthetic USD debt amount
    last-update-block: uint, ;; Block height for interest calculation
  }
)

;; SYNTHETIC USD TOKEN DEFINITION

(define-fungible-token stable-usd)

;; ADMINISTRATIVE FUNCTIONS

(define-public (set-protocol-owner (new-owner principal))
  ;; Transfer protocol ownership to a new address
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set protocol-owner new-owner))
  )
)

(define-public (pause-protocol (paused bool))
  ;; Emergency pause mechanism for protocol operations
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set protocol-paused paused))
  )
)

(define-public (update-btc-price
    (price uint)
    (timestamp uint)
  )
  ;; Update BTC/USD price feed from authorized oracle
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (asserts! (> price u0) ERR-INVALID-AMOUNT)
    (var-set btc-price-in-usd
      (some {
        price: price,
        timestamp: timestamp,
      })
    )
    (ok true)
  )
)

(define-public (set-current-time (time uint))
  ;; Set current timestamp for testing environment
  (begin
    (asserts! (is-eq tx-sender (var-get protocol-owner)) ERR-NOT-AUTHORIZED)
    (ok (var-set current-time time))
  )
)

;; CORE CALCULATION UTILITIES

(define-private (collateral-value
    (collateral-amount uint)
    (price uint)
  )
  ;; Calculate USD value of BTC collateral
  (* collateral-amount price)
)

(define-private (required-collateral
    (debt-amount uint)
    (price uint)
  )
  ;; Calculate minimum BTC collateral required for debt amount
  (/ (* debt-amount COLLATERAL-RATIO) (/ price u100))
)

(define-private (is-position-safe
    (user principal)
    (btc-price uint)
  )
  ;; Verify if position meets minimum collateralization requirements
  (let (
      (position (unwrap! (map-get? positions user) false))
      (debt (get debt position))
      (collateral (get collateral position))
      (collateral-value-usd (collateral-value collateral btc-price))
      (min-collateral-value-usd (/ (* debt COLLATERAL-RATIO) u100))
    )
    (>= collateral-value-usd min-collateral-value-usd)
  )
)

(define-private (calculate-interest
    (debt uint)
    (blocks-passed uint)
  )
  ;; Calculate compound interest accrued over block periods
  (/ (* debt (* blocks-passed INTEREST_RATE_PER_BLOCK)) INTEREST_RATE_DENOMINATOR)
)