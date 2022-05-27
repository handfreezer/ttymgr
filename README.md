# **Projet ttyMgr & Kiosk**

**Ce projet N'EST PAS libre de droit, d'usage,... Il faut un accord écrit de l'auteur pour une quelconque utilisation avec un aspect finanacier : que ce soit de vente de produit ou de service. Il doit toujours être fait mention du projet d'origine de manière claire. Toute modification doit faire l'objet d'un PR ici.**

Ce projet a pour objectif de faire un POC fonctionnel, scalable et sécurisable d'un point de concentration de pilotage de console distante graphique.

Le service cible de démonstration à piloter est l'affichage d'un site WEB, mais on peut envisager de déployer n'importe quel service ou application et la piloter par la suite.

**Pour l'instant, la console de gestion hébergeant TOUT (OpenVPN, HTTPD, InfluxDB, Grafana, Guacamole, FusionInventory, ...) tourne sur un simple Raspberry Pi 3, accueille 10 consoles, et on ne dépasse pas le 0,5 de load average sur 1 minute !** *:-)*

Entre autre, ce projet inclut de base:
* l'énumération des consoles à enroller en attente (VPN isolé A)
* l'enrollement avec l'établissement d'un VPN nominatif (VPN isolé B)
* le déploiement d'un service
* le relevé d'indicateur système basique pour un monitoring (mais n'importe quel indicateur pourrait être relevé)
* un splashscreen en mode tty sympa (avec affichage de l' MAC et de l'IP) à partir du moement où la console attend la validation de l'enrollement
* un mode Kiosk
* un mode scan GPS
* un mode scan WiFi
* un monitoring basique
* un browser de filesystem distant
* un mode scan avec FusionInventory
* une prise en main à distance via https>html5>vpn>console : protocole SSH/VNC/XRDP ( usage du projet Apache Guacamole )

Mais il y a encore beaucoup à faire:
* un gros nettoyage dans les scripts pour centraliser la conf global
* l'intégration de Wireguard (moins gourmand en ressource, intégré au kernel, broadband network reliable (3G/4G/5G/...))
* le split fonctionnel des fonctions (séparer l'infra de connexion de l'infra de service de l'infra de sécurité)
* intégrer un outil comme Ansible pour ne pas tout faire à la main dans des scripts, c'est mal!
* migrer en debian11, puis offrif une gestion plus multiplateforme
* finir la migration dans le framework graphique "jolie" (fini les tableaux à la main...)
* intégrer un framework PHP avec un router pour faire un vrai MVC ...
* et le reste
