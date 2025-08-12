# Decentralized Public Curb and Gutter Maintenance Services

A comprehensive blockchain-based system for managing municipal curb and gutter maintenance operations using Clarity smart contracts on the Stacks blockchain.

## System Overview

This system consists of five interconnected smart contracts that manage different aspects of curb and gutter maintenance:

### 1. Curb Repair Coordination Contract (`curb-repair.clar`)
- Manages repair and replacement requests for damaged concrete curbing
- Tracks repair status, contractor assignments, and completion verification
- Handles cost estimation and payment processing
- Maintains quality assurance records

### 2. Gutter Cleaning Scheduling Contract (`gutter-cleaning.clar`)
- Coordinates regular cleaning of street gutters and drainage channels
- Manages seasonal cleaning schedules and emergency cleanings
- Tracks cleaning crew assignments and completion status
- Monitors debris removal and disposal

### 3. Curb Painting Management Contract (`curb-painting.clar`)
- Manages painting of fire lanes, no parking zones, and loading areas
- Coordinates paint type selection and color standards
- Tracks painting schedules and weather-dependent delays
- Maintains compliance with municipal regulations

### 4. Storm Water Inlet Maintenance Contract (`storm-inlet.clar`)
- Ensures proper function of street-level water collection systems
- Manages inspection schedules and maintenance tasks
- Tracks blockage reports and clearing operations
- Monitors water flow capacity and structural integrity

### 5. Driveway Approach Permit Contract (`driveway-permit.clar`)
- Issues permits for residential and commercial driveway connections
- Manages application review and approval process
- Tracks permit fees and compliance requirements
- Maintains records of approved installations

## Key Features

- **Decentralized Governance**: Community-driven decision making for maintenance priorities
- **Transparent Operations**: All maintenance activities recorded on-chain
- **Automated Scheduling**: Smart contract-based scheduling and notifications
- **Quality Assurance**: Built-in verification and approval processes
- **Cost Management**: Transparent budgeting and expense tracking
- **Contractor Management**: Decentralized contractor selection and payment

## Data Structures

### Common Data Types
- **Location**: Street address and GPS coordinates
- **Status**: Pending, In Progress, Completed, Failed
- **Priority**: Low, Medium, High, Emergency
- **Cost**: Estimated and actual costs in STX tokens

### Contract-Specific Data
- **Repair Records**: Damage assessment, materials needed, completion photos
- **Cleaning Schedules**: Frequency, seasonal adjustments, crew assignments
- **Painting Specifications**: Color codes, paint types, regulatory compliance
- **Inlet Inspections**: Flow capacity, structural condition, blockage status
- **Permit Applications**: Property details, connection specifications, fees

## Installation and Setup

1. Install Clarinet CLI
2. Clone this repository
3. Run `clarinet check` to validate contracts
4. Run `npm test` to execute test suite
5. Deploy contracts using `clarinet deploy`

## Testing

The system includes comprehensive tests using Vitest:
- Unit tests for each contract function
- Integration tests for cross-contract workflows
- Edge case testing for error conditions
- Performance testing for large datasets

## Usage Examples

### Reporting a Curb Repair
\`\`\`clarity
(contract-call? .curb-repair report-damage
"123 Main St"
{x: u1000, y: u2000}
"Large crack in curbing"
u3)
\`\`\`

### Scheduling Gutter Cleaning
\`\`\`clarity
(contract-call? .gutter-cleaning schedule-cleaning
"Oak Street Block 1"
u1640995200
u2)
\`\`\`

### Applying for Driveway Permit
\`\`\`clarity
(contract-call? .driveway-permit submit-application
"456 Elm Ave"
"residential"
u12)
\`\`\`

## Governance

The system includes decentralized governance features:
- Community voting on maintenance priorities
- Budget allocation decisions
- Contractor performance evaluation
- Policy updates and improvements

## Security Features

- Multi-signature requirements for high-value operations
- Time-locked functions for critical changes
- Access control for administrative functions
- Audit trails for all maintenance activities

## Future Enhancements

- Integration with IoT sensors for automated monitoring
- Mobile app for citizen reporting
- AI-powered predictive maintenance
- Integration with weather data for scheduling optimization

