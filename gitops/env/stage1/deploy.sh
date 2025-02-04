#!/bin/bash

helm repo add argocd https://argoproj.github.io/argo-helm
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace --version 0.10.4

kubectl apply -f argocd-secrets.yaml
helm install argocd argocd/argo-cd --namespace argocd --create-namespace --values ./argocd-values.yaml --version 7.6.12

kubectl apply -f argocd-config.yaml
