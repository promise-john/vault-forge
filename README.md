# VaultForge: Advanced Bitcoin Collateral Protocol

VaultForge is a revolutionary DeFi protocol that enables Bitcoin holders to unlock liquidity without selling their BTC. By creating synthetic USD positions backed by Bitcoin collateral, users can access capital while maintaining their Bitcoin exposure through sophisticated over-collateralized debt positions with dynamic risk management.

## 🎯 Key Features

- **Multi-tier Collateralization System**: Advanced collateral management with automated liquidation protection
- **Dynamic Interest Rate Accrual**: Compound interest calculations based on protocol utilization
- **Real-time Price Oracle Integration**: Staleness protection and reliable price feeds
- **Automated Liquidation Mechanism**: Decentralized liquidation with proper incentive alignment
- **Emergency Protocol Controls**: Enhanced security with administrative pause functionality
- **Institutional-grade Reliability**: Built for enterprise use with retail accessibility

## 📋 System Overview

VaultForge operates as an over-collateralized lending protocol where users deposit Bitcoin as collateral to mint synthetic USD tokens. The protocol maintains system stability through:

1. **Minimum Collateralization**: 150% collateral ratio requirement
2. **Liquidation Protection**: Automatic liquidation at 120% ratio
3. **Interest Accrual**: Continuous compound interest on debt positions
4. **Price Oracle**: Real-time BTC/USD price feeds with expiry validation

### Protocol Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Minimum Collateral Ratio | 150% | Required collateralization for new positions |
| Liquidation Threshold | 120% | Ratio at which positions become liquidatable |
| Liquidation Penalty | 10% | Bonus for liquidators |
| Minimum Loan | 100 USD | Smallest debt position allowed |
| Interest Rate | ~10% APR | Compound interest on debt positions |
| Price Expiry | 24 hours | Maximum age for price data |

## 🏗️ Contract Architecture

### Core Components

```text
VaultForge Protocol
├── Administrative Layer
│   ├── Protocol Owner Management
│   ├── Emergency Pause Controls
│   └── Oracle Price Updates
├── Position Management
│   ├── Debt Position Tracking
│   ├── Collateral Management
│   └── Interest Accrual Engine
├── Risk Management
│   ├── Collateralization Validation
│   ├── Liquidation Engine
│   └── Price Oracle Integration
└── Token System
    └── Synthetic USD (stable-usd) Token
```

### Data Structures

#### Position Mapping

```clarity
positions: {
  principal → {
    collateral: uint,        // BTC amount in satoshis
    debt: uint,             // Synthetic USD debt
    last-update-block: uint // Last interest calculation block
  }
}
```

#### Global State Variables

- `total-debt`: Total synthetic USD in circulation
- `total-collateral`: Total BTC locked as collateral
- `stability-fee`: Accumulated protocol fees
- `btc-price-in-usd`: Current price feed with timestamp

## 📊 Data Flow

### Position Creation Flow

```text
User Request → Price Validation → Collateral Check → Position Update → Token Mint
     ↓              ↓                ↓                ↓              ↓
 Input Validation   Oracle Check     Ratio Calc      State Update   sUSD Issue
```

### Interest Accrual Flow

```text
Block Update → Global Interest → Position Interest → Debt Update
     ↓              ↓                ↓                ↓
 Time Passed    Protocol Fees    Individual Calc   Position State
```

### Liquidation Flow

```text
Price Drop → Health Check → Liquidation Trigger → Collateral Transfer
     ↓            ↓              ↓                     ↓
 Oracle Update   Ratio Check    Liquidator Action    Penalty Applied
```

## 🚀 Core Functions

### User Operations

#### `create-position`

Creates new collateralized debt position or expands existing one.

```clarity
(create-position btc-amount stable-amount)
```

#### `add-collateral`

Adds additional BTC collateral to improve position health.

```clarity
(add-collateral btc-amount)
```

#### `repay-debt`

Repays synthetic USD debt, potentially closing the position.

```clarity
(repay-debt amount)
```

#### `withdraw-collateral`

Withdraws excess collateral while maintaining safe ratios.

```clarity
(withdraw-collateral btc-amount)
```

### Liquidation

#### `liquidate-position`

Liquidates undercollateralized positions with penalty rewards.

```clarity
(liquidate-position user-principal)
```

### Administrative Functions

#### `update-btc-price`

Updates BTC/USD price feed from authorized oracle.

```clarity
(update-btc-price price timestamp)
```

#### `pause-protocol`

Emergency pause mechanism for protocol operations.

```clarity
(pause-protocol paused-bool)
```

## 📖 Read-Only Functions

### `get-position`

Retrieves user's current position details including collateral, debt, and last update block.

### `get-collateralization-ratio`

Calculates current collateralization ratio for a user's position.

### `get-protocol-stats`

Returns comprehensive protocol statistics including total debt, collateral, and system state.

### `get-current-price`

Retrieves current BTC price with staleness validation.

## 🔒 Security Features

### Risk Management

- **Over-collateralization**: 150% minimum ratio ensures system stability
- **Liquidation Threshold**: 120% ratio triggers automatic liquidation
- **Price Staleness Protection**: 24-hour expiry on price data
- **Interest Rate Caps**: Controlled compound interest accrual

### Access Controls

- **Protocol Owner**: Administrative functions restricted to owner
- **Emergency Pause**: Global protocol pause capability
- **Oracle Authorization**: Only authorized addresses can update prices

### Validation Checks

- **Minimum Loan Amount**: Prevents dust positions
- **Collateral Sufficiency**: Continuous ratio validation
- **Amount Validation**: Non-zero and positive amount checks

## 🧪 Testing

The protocol includes comprehensive test coverage for:

- Position creation and management
- Interest accrual calculations
- Liquidation scenarios
- Oracle price updates
- Administrative functions

Run tests with:

```bash
npm test
```

Check contracts with Clarinet:

```bash
clarinet check
```

## 🚀 Deployment

VaultForge is designed for deployment on the Stacks blockchain, leveraging Bitcoin's security while enabling smart contract functionality.

### Environment Configuration

- **Devnet**: Development and testing environment
- **Testnet**: Public testing with test tokens
- **Mainnet**: Production deployment with real assets

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## ⚠️ Disclaimer

VaultForge is experimental DeFi software. Users should understand the risks involved with collateralized lending protocols, including but not limited to:

- Smart contract risk
- Liquidation risk
- Oracle failure risk
- Market volatility risk
