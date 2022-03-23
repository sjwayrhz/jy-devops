{{- define "nginx.ingress.http" }}
nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
nginx.ingress.kubernetes.io/ssl-redirect: "false"
{{ end }}

{{- define "nginx.ingress.https" }}
nginx.ingress.kubernetes.io/ssl-redirect: "true"
{{ end }}

{{- define "nginx.ingress.httpsOnly" }}
nginx.ingress.kubernetes.io/ssl-redirect: "true"
nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
{{ end }}

{{- define "nginx.ingress.enableTls" }}
tls:
  - hosts:
      - {{ .Values.project.fqdn }}
    secretName: wfl-ischool.cn-2021-04-29
{{ end }}
