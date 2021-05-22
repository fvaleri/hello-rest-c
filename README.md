# hello-rest-c

This is the skeleton of a REST-based webservice, implemented in C, and
using GNU microhttpd as the HTTP server. It comes from a discussion
with colleagues about what consitutes a "microservice" in modern practice.
The ability of GraalVM to create a native binary from Java is impressive, but I
find it hard to think of a 27Mb (stripped) binary size as a "microservice".

This C version has a compiled code size of 23kB, and a total memory footprint of
about 4Mb. That's including all the SSL support, which isn't used in the example,
and code to parse the headers and URI arguments which, again, isn't used here.

Run the service like this:
```sh
./hello-rest-c --debug
```

Then invoke it like this:
```sh
curl http://localhost:8080/greet/fred
{"hello": "fred"}
```

As well as a `/greet` API, there's also a `/health` API, that just returns
an OK message, and a `/metrics` API that returns request counts.

The actual implementation of the service, such as it is, is in
`request_handler.c`. The rest of the code just starts the HTTP server, parses
the command line, handles signals, and does logging.

To build the example you'll need the libmicrohttpd development files
-- e.g., `dnf install libmicrohttpd-devel` (lnx) or `brew install libmicrohttpd`
(mac). Although libmicrohttpd has dependencies, I don't think my code has any
dependencies of its own.

## Run on Kubernetes

Run the lightweight image built from the `Dockerfile` in any Kubernetes distribution.

```sh
kubectl create namespace test
kubectl config set-context --current --namespace=test

kubectl create deployment hello --image="quay.io/fvaleri/hello-rest-c:latest"
kubectl expose deployment hello --name=hello-service --port=8080
kubectl create -f - <<EOF
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: hello-ingress
  namespace: test
spec:
  rules:
    - host: hello.minikube.io
      http:
        paths:
          - path: /
            backend:
              serviceName: hello-service
              servicePort: 8080
EOF

sudo echo "$(minikube ip) hello.minikube.io" >> /etc/hosts

HOST="$(oc get ingress hello-ingress -o=jsonpath='{.spec.rules[0].host}{"\n"}')"
curl http://$HOST/greet/fede
```
