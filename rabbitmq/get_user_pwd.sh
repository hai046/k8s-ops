username="$(kubectl get secret warm-rabbit-cluster-default-user -n warm-prod -o jsonpath='{.data.username}' | base64 --decode)" && echo "username: $username"

password="$(kubectl get secret warm-rabbit-cluster-default-user -n warm-prod -o jsonpath='{.data.password}' | base64 --decode)" && echo "password: $password"
