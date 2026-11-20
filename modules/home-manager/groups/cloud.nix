{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Kubernetes
    kubectl
    kubernetes-helm
    minikube
    k9s
    argocd

    # Infrastructure as code
    opentofu
    terragrunt
  ];
}
