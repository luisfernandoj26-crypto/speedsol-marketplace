# Risk Assessment Matrix

## Severity Levels

### Critical (Immediate Action Required)
- Exploitable security vulnerabilities
- Unauthorized data access
- System unavailability
- Data loss risk

### High (Fix Before Release)
- Missing authentication/authorization
- Weak encryption
- No logging on sensitive operations
- Missing backups

### Medium (Should Be Fixed)
- Code quality issues
- Incomplete documentation
- Manual processes that could be automated
- Outdated dependencies

### Low (Best Practice Improvements)
- Code style inconsistencies
- Minor performance issues
- Documentation clarity
- Logging improvements

## Risk Calculation

Risk = Probability × Impact

### Probability Scores
- High (3): Easily exploitable, multiple vectors
- Medium (2): Requires specific conditions
- Low (1): Difficult to exploit

### Impact Scores
- High (3): Critical system/data impact
- Medium (2): Significant operational impact
- Low (1): Minor impact

## Remediation Timeline

- Critical: 24 hours
- High: 1 week
- Medium: 30 days
- Low: Next sprint
