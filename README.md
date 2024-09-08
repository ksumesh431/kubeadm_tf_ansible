# Basic terraform setup prerequisite

- Have an account ready to be used with terraform and set it up using the aws cli
- Ansible installed

# verify that everything works

```bash
kubectl get nodes
kubectl run nginx --image=nginx:alpine
kubectl expose pod nginx --name=demo-svc --port 8000 --target-port=80
kubectl get svc -o wide
kubectl run temp --image=nginx:alpine --rm -it --restart=Never -- curl http://demo-svc:8000
```