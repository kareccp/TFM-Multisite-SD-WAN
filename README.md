# TFM-OSPF-SD-WAN-FlowManager

Repositorio del Trabajo Fin de Máster.

Este proyecto implementa una arquitectura SD-WAN multisede basada en:

- FRR
- OSPF
- Kubernetes
- Open vSwitch
- OS-Ken
- FlowManager

1. Descargar e importar en VirtualBox la máquina virtual.

Se va a utilizar la misma maquina virtual utilizada en la asignatura: 

RDSV-K8S-2024-v2.ova

https://idefix.dit.upm.es/download/vnx/vnx-vm/RDSV-K8S-2024-v2.ova

Importarla en VirtualBox y arrancarla.

2. Comprobación del entorno

Una vez iniciada la maquina virtual se debe comprobar que todas las herramientas que se van a utilizar se encuentran disponibles.

git --version
docker --version
microk8s status
microk8s kubectl get nodes
helm version
sudo vnx --version

La maquina virtual puede contener pods antiguos pertenecientes a despliegues anteriores, estos pods deben eliminarse antes de comenzar

helm uninstall access1 -n default 2>/dev/null || true
helm uninstall cpe1 -n default 2>/dev/null || true

microk8s kubectl delete pod --all -n default --force --grace-period=0 2>/dev/null || true

microk8s kubectl get pods -A
helm list -A

3. Descargar el repositorio del proyecto

Se aconseja crear una carpeta compartida donde descargues el repositorio, por ejemplo la misma carpeta que fue utilizada en practicas anteriores shared.

cd ~/shared
git clone https://github.com/kareccp/TFM-Multisite-SD-WAN.git

despues verificamos si el contenido se ha descargado correctamente:
cd TFM-Multisite-SD-WAN
ls

y damos permisos a los scripts:
chmod +x *.sh
chmod +x bin/*

4. Preparación del repositorio Helm local

Fuera de la carpeta shared, cree una carpeta para almacenar los ficheros del repositorio helm, que va a publicar utilizando un contenedor de Docker.

mkdir -p $HOME/helm-files
cd ~/helm-files

Crear los paquetes Helm:

cd ~/helm-files
helm package ~/shared/TFM-Multisite-SD-WAN/helm/accesschart
helm package ~/shared/TFM-Multisite-SD-WAN/helm/cpechart
helm package ~/shared/TFM-Multisite-SD-WAN/helm/wanchart

Crear el índice Helm:

helm repo index --url http://127.0.0.1:8080/ .

Arrancar servidor web:

docker rm -f helm-repo 2>/dev/null || true

docker run --restart always --name helm-repo -p 8080:80 -v ~/helm-files:/usr/share/nginx/html:ro -d nginx

Comprobar que se puede acceder al repositorio:

curl http://127.0.0.1:8080/index.yaml

debe aparecer accesschart, cpechart y wanchart.




