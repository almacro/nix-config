{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Kubernetes
    (lib.hiPrio kubectl)
    kubernetes-helm
    minikube
    k9s
    argocd

    # Infrastructure as code
    opentofu
    terragrunt
  ];
}
