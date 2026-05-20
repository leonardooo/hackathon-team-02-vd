# Operational Runbook: generate-payment-cycle

**Feature**: 001
**Last Updated**: 2026-05-20T18:39:13.795Z

## Deployment
1. Build: `npm run build`
2. Test: `npm test`
3. Deploy: Follow CI/CD pipeline

## Monitoring
- Health check: `GET /health`
- Logs: Check application logs for errors

## Troubleshooting
| Symptom | Cause | Resolution |
|---------|-------|-----------|
| 500 errors | Database connection | Check connection string |
| Slow responses | High load | Scale horizontally |
| Auth failures | Token expiry | Check token configuration |

## Rollback
1. Revert deployment to previous version
2. Verify health checks pass
3. Notify team
