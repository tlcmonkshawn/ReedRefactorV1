# Secrets Setup - Status

## ✅ Completed

The following secrets have been created in Secret Manager:

1. ✅ **SECRET_KEY_BASE** - Generated and saved to `.secret_key_base`
2. ✅ **JWT_SECRET_KEY** - Created (uses same value as SECRET_KEY_BASE)
3. ✅ **ADMIN_PASSWORD** - Created (value: "iamagoodgirl")
4. ✅ **GOOGLE_APPLICATION_CREDENTIALS_JSON** - Created from `service-account-key.json`

## ⚠️ Pending

5. ⚠️ **GEMINI_API_KEY** - Not created yet

   To create this secret, run:
   ```powershell
   'your-gemini-api-key-here' | gcloud secrets create GEMINI_API_KEY --data-file=- --project=reed-bootie-hunter
   ```

   Or if you have it in an environment variable:
   ```powershell
   $env:GEMINI_API_KEY | gcloud secrets create GEMINI_API_KEY --data-file=- --project=reed-bootie-hunter
   ```

## Next Steps

1. Create GEMINI_API_KEY secret (if you have the key)
2. Grant Cloud Run service account access to secrets:
   ```powershell
   .\scripts\grant-secret-access.ps1
   ```
   Or manually:
   ```powershell
   $PROJECT_NUMBER = (gcloud projects describe reed-bootie-hunter --format="value(projectNumber)")
   $SERVICE_ACCOUNT = "$PROJECT_NUMBER-compute@developer.gserviceaccount.com"
   
   gcloud secrets add-iam-policy-binding SECRET_KEY_BASE --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/secretmanager.secretAccessor" --project=reed-bootie-hunter
   # Repeat for each secret: JWT_SECRET_KEY, ADMIN_PASSWORD, GOOGLE_APPLICATION_CREDENTIALS_JSON, GEMINI_API_KEY
   ```

## Verification

List all secrets:
```powershell
gcloud secrets list --project=reed-bootie-hunter
```

View a secret (for verification):
```powershell
gcloud secrets versions access latest --secret="SECRET_KEY_BASE" --project=reed-bootie-hunter
```

