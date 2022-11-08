# Demo Steps

## Install kind

```bash
kind create cluster --name sigstore-demo --config manifests/kind-config.yaml
```

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
```

```bash
helm install kyverno kyverno/kyverno -n next-demo --create-namespace
```

## Configure policy


```bash
kubectl apply -f manifests/imagePolicy.yaml --namespace next-demo
```

Run bad image, fails

```bash
kubectl run bad-image --image=ghcr.io/lukehinds/blackhat-next-security-demo:main
```

Run good image, runs

```bash
kubectl run good-image --image=ghcr.io/lukehinds/redhat-next-security-demo:main
```

## Delete image

```bash
kubectl delete pod good-image --now
```

Add lhinds@redhat.com to policy, and apply config 

```yaml
- keyless:
    subject: "lhinds@redhat.com"
    issuer: "https://github.com/login/oauth"
```

```bash
kubectl apply -f manifests/imagePolicy.yaml --namespace next-demo
```

Run good image, runs

```bash
kubectl run good-image --image=ghcr.io/lukehinds/redhat-next-security-demo:main
```

## Sign with cosign

```bash
cosign sign ghcr.io/lukehinds/redhat-next-security-demo:main
```

Look up signature and cert in rekor and set 

```bash
logindex=12345
```

```bash
rekor-cli get --log-index 3482746 --format=json | jq ".Body | .HashedRekordObj | .signature | .publicKey | .content" | cut -d '"' -f2 | base64 -D
```

## Show certificate

```bash
openssl x509 -in cert.pem -text
```

Run good image, runs

```bash
kubectl run good-image --image=ghcr.io/lukehinds/redhat-next-security-demo:main
```

