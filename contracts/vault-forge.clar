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