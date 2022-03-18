# sh labels-on-master.sh $(node name)
# Example
# sh labels-on-master.sh k8s-master-01
# sh labels-on-master.sh k8s-master-02
# sh labels-on-master.sh k8s-master-03
kubectl label nodes $1 kubernetes.io/ingress=nginx-ingress
