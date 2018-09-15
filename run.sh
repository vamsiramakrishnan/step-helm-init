#!/bin/sh

helm="$WERCKER_STEP_ROOT/helm"
kubectl="$WERCKER_STEP_ROOT/kubectl"

main() {
  display_helm_kubectl_version
  
#   if [ -z "$WERCKER_HELM_INSTALL_COMMAND" ]; then
#     fail "wercker-helm: command argument cannot be empty"
#   fi

  cmd="cluster-info"
  helm_cmd="$WERCKER_HELM_INSTALL_COMMAND"
 
  helm_args=
  # client only
  if [ -n "$WERCKER_HELM_INSTALL_CLIENT_ONLY" ]; then
    helm_args ="$helm_args --client-only"
  fi
   
  # release-name
  if [ -n "$WERCKER_HELM_INSTALL_RELEASE_NAME" ]; then
    helm_args ="$helm_args --name=\"$WERCKER_HELM_INSTALL_RELEASE_NAME\""
  fi

  # release-namespace
  if [ -n "$WERCKER_HELM_INSTALL_RELEASE_NAMESPACE" ]; then
    helm_args ="$helm_args --namespace=\"$WERCKER_HELM_INSTALL_RELEASE_NAMESPACE\""
  fi

  # repo
  if [ -n "$WERCKER_HELM_INSTALL_REPO" ]; then
    helm_args ="$helm_args --repo=\"$WERCKER_HELM_INSTALL_REPO\""
  fi

  # chart-name
  if [ -n "$WERCKER_HELM_INSTALL_CHART_NAME" ]; then
    helm_args ="$helm_args \"$WERCKER_HELM_INSTALL_CHART_NAME\""
  fi 

  #chart-directory
  if [ -n "$WERCKER_HELM_INSTALL_SOURCE" ]; then
    helm_args ="$helm_args \"$WERCKER_HELM_INSTALL_CHART_DIRECTORY\""
  fi 

 # values file
  if [ -n "$WERCKER_HELM_INSTALL_VALUES_FILE" ]; then
    $WERCKER_STEP_ROOT/envsubst < "$WERCKER_HELM_INSTALL_VALUES_FILE" > "$HOME/values.yaml"
    helm_args ="$helm_args -f \"$HOME/values.yaml\""
  fi 

  # Global args
  #global_args
  global_args=
  raw_global_args="$WERCKER_HELM_INSTALL_RAW_GLOBAL_ARGS"

  # token
  if [ -n "$WERCKER_HELM_INSTALL_TOKEN" ]; then
    global_args="$global_args --token=\"$WERCKER_HELM_INSTALL_TOKEN\""
  fi

  # username
  if [ -n "$WERCKER_HELM_INSTALL_USERNAME" ]; then
    global_args="$global_args --username=\"$WERCKER_HELM_INSTALL_USERNAME\""
  fi

  # password
  if [ -n "$WERCKER_HELM_INSTALL_PASSWORD" ]; then
    global_args="$global_args --password=\"$WERCKER_HELM_INSTALL_PASSWORD\""
  fi

  # server
  if [ -n "$WERCKER_HELM_INSTALL_SERVER" ]; then
    global_args="$global_args --server=\"$WERCKER_HELM_INSTALL_SERVER\""
  fi

  # insecure-skip-tls-verify
  if [ -n "$WERCKER_HELM_INSTALL_INSECURE_SKIP_TLS_VERIFY" ]; then
    global_args="$global_args --insecure-skip-tls-verify=\"$WERCKER_HELM_INSTALL_INSECURE_SKIP_TLS_VERIFY\""
  fi
    # certificate-authority
  if [ -n "$WERCKER_HELM_INSTALL_CERTIFICATE_AUTHORITY" ]; then
    global_args="$global_args --certificate-authority=\"$WERCKER_HELM_INSTALL_CERTIFICATE_AUTHORITY\""
  fi
    # client-certificate
  if [ -n "$WERCKER_HELM_INSTALL_CLIENT_CERTIFICATE" ]; then
    global_args="$global_args --client-certificate=\"$WERCKER_HELM_INSTALL_CLIENT_CERTIFICATE\""
  fi
    # client-key
  if [ -n "$WERCKER_HELM_INSTALL_CLIENT_KEY" ]; then
    global_args="$global_args --client-key=\"$WERCKER_HELM_INSTALL_CLIENT_KEY\""
  fi


  mkdir -p $HOME/.kube
  $WERCKER_STEP_ROOT/envsubst < "$WERCKER_STEP_ROOT/config" > "$HOME/.kube/config"

  # export KUBECONFIG= $HOME/.kube/config
  info "Connecting to the Cluster as specified in kubeconfig"
  $kubectl cluster-info --kubeconfig $HOME/.kube/config
  

  info "Initializing Helm"
  "$helm" init --service-account tiller --kubeconfig $HOME/.kube/config --upgrade
  info "Executing Helm Command"
  eval "$helm" install "$helm_args" 

}

display_helm_kubectl_version() {
  info "Running kubectl version:"
  "$kubectl" version --client
  echo ""
  info "Running helm version:"
  "$helm" version --client
  echo ""
}

main;
