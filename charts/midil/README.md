## Using SealedSecrets with this chart

SealedSecrets allow you to safely store encrypted Kubernetes secrets in Git, which are decrypted and managed by the SealedSecrets controller in your cluster. This chart supports SealedSecrets out of the box.

### Step-by-step guide

1. **Create your Kubernetes Secret manifest (dry-run):**
   ```bash
   kubectl create secret generic onekg-secrets \
     --from-literal=DB_USER=produser \
     --from-literal=DB_PASS=prodpass \
     --dry-run=client -o yaml > secret.yaml
   ```

2. **Encrypt the secret using kubeseal:**
   ```bash
   kubeseal --format yaml < secret.yaml > sealedsecret.yaml
   ```
   > *Note: You need access to the SealedSecrets controller's public key or a running controller in your cluster.*

3. **Add the sealed secret to your chart or GitOps repository:**
   - **Option A:** Place `sealedsecret.yaml` in the `files/` directory of your chart and reference it using `.Files.Get`.
   - **Option B:** Copy the entire sealed YAML and paste it into your `values.yaml` under `secrets.sealed.manifests` as a YAML string.

   **Example `values.yaml` snippet:**
   ```yaml
   secrets:
     enabled: true
     mode: sealed
     nameOverride: "onekg-secrets"
     sealed:
       manifests:
         - |
           apiVersion: bitnami.com/v1alpha1
           kind: SealedSecret
           metadata:
             name: onekg-secrets
           spec:
             encryptedData:
               DB_PASS: AgC...
               DB_USER: AgC...
   ```

4. **Install or upgrade the chart:**
   The SealedSecrets controller will automatically unseal the secret and create the corresponding Kubernetes Secret in your namespace.

### Notes

- By default, the chart expects the Secret to be named `"<fullname>-secrets"`. You can override this with `secrets.nameOverride`.
- Storing sealed manifests in Git is safe, as they are encrypted and cannot be decrypted without the cluster's private key.

---

## Design Notes & Rationale

- The `secrets.mode` value centralizes secret management, letting you explicitly choose the source and handling of secrets.
- The `inline` mode is convenient for development or testing, but **should not be used in production**.
- The `external` mode integrates with the ExternalSecrets operator, supporting backends like Vault or cloud secret managers.
- The `sealed` mode enables safe, GitOps-friendly secret management using SealedSecrets.
- The chart only mounts secrets/config when enabled, and uses `envFrom` for clean environment injection.
- The included `values.schema.json` provides basic validation to help catch misconfigurations early.
