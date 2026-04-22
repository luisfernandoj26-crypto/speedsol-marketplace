# Command: /audit-soc2

## Purpose

Execute a comprehensive SOC 2 compliance audit of the entire project. Generates a detailed report with findings, risks, and recommendations.

## How It Works

1. Scans ALL project files
2. Evaluates against SOC 2 controls framework
3. Checks compliance rules
4. Assesses risks (probability × impact)
5. Generates detailed report
6. Saves to `/auditoria/YYYY-MM-DD-informe.md`

## Usage

```
/audit-soc2
```

## Output

Complete audit report saved to `/auditoria/` with:
- Critical, High, Medium, Low findings
- Risk assessment matrix
- Compliance percentage by area
- Actionable recommendations
- Remediation timeline

## After Audit

1. Review findings in generated report
2. Use other plugins to fix issues
3. Run `/audit-soc2` again to re-evaluate
4. Track remediation progress

## Frequency

- Initial: Before first release
- Periodic: Quarterly or after major changes
- Post-Fix: After addressing high/critical findings
