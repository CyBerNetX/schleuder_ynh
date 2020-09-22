#Documentation pour les administrateurs du serveur

Ce document fait référence à la version 3.5 de Schleuder. Pour en savoir plus sur les anciennes versions de Schleuder, veuillez consulter les anciens documents.

    Configuration de Schleuder
        Installation
            Debian
        Configuration
        Accrochez-vous à l'agent de transport du courrier
            Postfix
        Schleuder API
            Cryptage des transports
            Authentification
    Gestion d'une liste
        schleuder-web
        schleuder-cli
    Maintenance

##Setup Schleuder
###Installation

Vous pouvez installer schleuder à partir de paquets de la distribution Linux ou de rubygems. Il existe actuellement des paquets de distribution supportés pour Debian ("buster" et supérieur) et CentOS 7. Si vous utilisez l'une des plateformes directement supportées, vous devez choisir les paquets plutôt que les gems.

N'utilisez pas les paquets fournis par Ubuntu dans toutes les versions jusqu'à la 17.10 incluse, ils sont gravement dépassés. Sur Ubuntu 18.04, n'utilisez le paquet que s'il a au moins la version 3.2.2.

Outre schleuder, vous devez également installer au moins un des outils suivants : schleuder-cli (l'outil en ligne de commande pour gérer les listes Schleuder), et schleuder-web (l'interface web pour gérer et maintenir les listes Schleuder).

De plus, nous vous recommandons d'utiliser une source entropique telle que haveged. Cela garantit que Schleuder ne sera pas bloqué par un manque d'entropie, ce qui pourrait autrement se produire, par exemple, lors de la génération des clés.
####Debian

L'étape nécessite des privilèges de root

Nous maintenons schleuder et schleuder-cli dans "buster" et au-dessus. (Pour une utilisation en production, nous recommandons Debian "buster".) Pour installer les paquets

  apt-get install schleuder schleuder-cli

Il n'est pas nécessaire de lancer l'installation de schleuder par la suite, le paquet s'en charge.
ps: debian 9 stretch utiliser les backports 

###Configuration

Schleuder lit ses paramètres de base à partir d'un fichier qu'il attend par défaut à /etc/schleuder/schleuder.yml. Pour que Schleuder lise un fichier différent, définissez la variable d'environnement SCHLEUDER_CONFIG sur le chemin de votre fichier lors de l'exécution de schleuder. Par exemple :

  SCHLEUDER_CONFIG=/usr/local/etc/schleuder.yml /path/to/bin/schleuder ...

Pour des explications sur les paramètres possibles, lisez le fichier de configuration par défaut (également disponible dans le dépôt).

Les paramètres par défaut pour les nouvelles listes sont lus dans un autre fichier de configuration. Par défaut, Schleuder consulte le fichier /etc/schleuder/list-defaults.yml. Pour que Schleuder lise un autre fichier, définissez la variable d'environnement SCHLEUDER_LIST_DEFAULTS comme ci-dessus. Les paramètres possibles sont expliqués dans le fichier de configuration par défaut, qui est également disponible dans le dépôt.

Une fois qu'une liste est créée, elle n'est plus affectée par ces fichiers de configuration. Les listes existantes ont leur configuration stockée dans la base de données. Les paramètres de la base de données peuvent être affichés et définis via l'API schleuder, disponible par le biais de schleuder-web ou schleuder-cli. Pour plus d'informations sur ces dernières, consultez l'aide des listes de schleuder-cli et les options de liste de schleuder-cli.
####Connexion à l'agent de transport du courrier

En mode "travail", Schleuder s'attend à ce que l'adresse électronique de la liste soit le deuxième argument (le premier est "travail") et que le courrier électronique entrant soit en entrée standard.

Pour permettre à Schleuder de recevoir des courriels, votre agent de transport de courrier doit être configuré en conséquence. La manière de procéder avec Postfix est décrite en détail ci-dessous.

####Postfix

Cette section ne décrit que les parties d'une configuration Postfix qui sont pertinentes pour Schleuder. Nous partons du principe que vous disposez déjà d'une configuration Postfix sensée et testée.

Tout d'abord, pour connecter Schleuder à Postfix, adaptez ces lignes (chemin et peut-être utilisateur) et ajoutez-les à master.cf :

  schleuder unix - n n - - pipe
    flags=DRhu user=schleuder argv=/path/to/bin/schleuder work ${recipient}

Ensuite, vous devez choisir la manière dont le postfix doit décider si un message doit être remis à Schleuder. Il y a deux options :

    Le configurer pour chaque liste individuellement. C'est la solution si vous n'avez pas beaucoup de listes, ou si vous utilisez le domaine correspondant pour un nombre variable de comptes de messagerie ou d'alias.
    Dédier un domaine entier à Schleuder. C'est la meilleure solution si vous utilisez plus de listes que de comptes de messagerie ou d'alias sur ce domaine.

Pour configurer chaque liste individuellement, ajoutez ces lignes au fichier main.cf :

  schleuder_destination_recipient_limit = 1
  transport_maps = hash:/etc/postfix/transport_schleuder

Adaptez maintenant les lignes suivantes pour chaque liste et ajoutez-les à /etc/postfix/transport_schleuder :

  foo@example.org schleuder :
  foo-request@example.org schleuder :
  foo-owner@example.org schleuder :
  foo-bounce@example.org schleuder :
  foo-sendkey@example.org schleuder :

Ensuite, lancez postmap /etc/postfix/transport_schleuder et redémarrez postfix. N'oubliez pas de répéter cette opération également pour les listes nouvellement créées plus tard.

Une autre façon d'indiquer à postfix quel domaine et quelle liste peuvent être transmis à schleuder est d'extraire ces informations de la base de données sqlite. Une condition pour cela est le paquet postfix-sqlite, qui n'est pas dans les dépôts standards de CentOS, mais de Debian.

Pour dédier un domaine entier à Schleuder, ajoutez ces lignes à main.cf :

  schleuder_destination_recipient_limit = 1
  virtual_mailbox_domains = sqlite:/etc/postfix/schleuder_domain_sqlite.cf
  virtual_transport = schleuder
  virtual_alias_maps = hash:/etc/postfix/virtual_aliases
  virtual_mailbox_maps = sqlite:/etc/postfix/schleuder_list_sqlite.cf

Ensuite, adaptez et ajoutez au moins les exceptions suivantes à la règle "All-to-Schleuder" dans /etc/postfix/virtual_aliases :

  postmaster@lists.example.org root@anotherdomain
  abuse@lists.example.org root@anotherdomain
  MAILER-DAEMON@lists.example.org root@anotherdomain
  root@lists.example.org root@anotherdomain

Ensuite, lancez postmap /etc/postfix/virtual_aliases.

Le fichier schleuder_domain_sqlite.cf peut demander à la base de données schleuder sqlite (ce qui déléguera tout le domaine à schleuder) :

dbpath = /var/lib/schleuder/db.sqlite
query = sélectionner une sous-rubrique distincte (email, instr(email, '@') + 1) dans les listes
        où le courrier électronique comme "%%%s

Et le fichier schleuder_list_sqlite.cf peut également obtenir les informations de la base de données schleuder sqlite :

  dbpath = /var/lib/schleuder/db.sqlite
  query = sélectionner "present" dans les listes
            où courriel = "%s".
            ou email = replace('%s', '-bounce@', '@')
            ou email = replace('%s', '-owner@', '@')
            ou email = replace('%s', '-request@', '@')
            ou email = replace('%s', '-sendkey@', '@')

Désormais, chaque liste Schleuder sera instantanément accessible par courrier électronique dès sa création.
###Schleuder API

L'API Schleuder est fournie par schleuder-api-daemon. Les clients de configuration (schleuder-web, schleuder-cli) l'utilisent pour accéder à des informations sur les listes, les abonnements et les clés. Comme vous souhaitez probablement utiliser au moins schleuder-cli depuis localhost, la configuration de schleuder-api-daemon est utile même sans clients distants.

Schleuder n'utilise pas schleuder-api-daemon pour traiter les courriels. Vous pouvez arrêter schleuder-api-daemon à tout moment sans interrompre le flux de courrier électronique.

Pour exécuter schleuder-api-daemon, selon le type de système d'exploitation et la configuration que vous utilisez, vous pouvez soit lancer le fichier d'unité système :

  systemctl démarrer schleuder-api-daemon

Ou vous pouvez l'exécuter manuellement dans un shell :

  schleuder-api-daemon

Veuillez prendre soin d'exécuter schleuder-api-daemon en tant qu'utilisateur propriétaire du répertoire des listes schleuder (par défaut /var/lib/schleuder/lists) pour éviter de rencontrer des problèmes de permission de fichiers !
####Cryptage du transport

schleuder-api-daemon utilise le chiffrement de transport (TLS) pour toutes les connexions. Les certificats TLS requis doivent avoir été générés lors de l'installation (installation de schleuder). Vous pouvez en générer de nouveaux à tout moment en les exécutant :

schleuder cert generate

Si les autorisations des systèmes de fichiers le permettent, Schleuder écrira le certificat et la clé directement dans les fichiers corrects (les chemins sont lus à partir du fichier de configuration). Sinon, vous risquez de devoir les déplacer. Veuillez lire la sortie de la commande ci-dessus pour d'éventuelles instructions.

Si vous disposez déjà d'un certificat approprié, vous pouvez l'utiliser également. Le nom d'hôte n'a pas d'importance. Il suffit de le copier dans les chemins d'accès spécifiés dans le fichier de configuration, ou de modifier ces chemins.

Afin de vérifier la connexion, chaque client doit connaître l'empreinte digitale du certificat API. L'empreinte digitale sera affichée lors de la génération des certificats. Plus tard, vous pouvez toujours la faire réapparaître en l'exécutant :

empreinte digitale du certificat schleuder

Utilisez des canaux sécurisés pour transporter ces informations !
####Authentification

L'API Schleuder utilise des clés API pour authentifier les clients.

Vous pouvez générer de nouvelles clés API en vous exécutant :

  schleuder new_api_key

Pour permettre au client de se connecter, sa clé API doit être ajoutée à la section valid_api_keys dans le fichier de configuration de Schleuder.

Fournissez à chaque client sa propre clé API, et utilisez des canaux sécurisés pour transporter ces informations !

Il n'y a pas encore d'autorisation des clients. Chaque client est autorisé à effectuer chaque action. Méfiez-vous donc de qui doit donner une clé API. schleuder-web a sa propre autorisation, mais pas schleuder-cli !
##Gestion d'une liste

Pour créer et gérer des listes, vous avez deux options : schleuder-web et schleuder-cli.

Les deux nécessitent un schleuder-api-daemon en cours d'exécution. Veuillez consulter la section précédente sur la manière de le configurer.
###schleuder-web

Pour créer des listes avec schleuder-web, connectez-vous en tant que root@localhost. La gestion des listes est autorisée à chaque administrateur de liste.
###schleuder-cli

Pour utiliser schleuder-cli, veuillez consulter le résultat de

aide schleuder-cli


##Maintenance

Veuillez faire en sorte que les commandes suivantes soient exécutées par l'utilisateur qui possède le répertoire des listes schleuder (par défaut /var/lib/schleuder/lists) pour éviter de rencontrer des problèmes de permission de fichiers !

Schleuder peut vérifier toutes les clés présentes dans les porte-clés de la liste pour les dates d'expiration (à venir), la révocation ou d'autres raisons de non utilisation.

Appelez cette commande chaque semaine depuis cron pour automatiser la vérification et faire envoyer les résultats aux administrateurs des listes respectives :

schleuder check_keys

Schleuder peut également rafraîchir toutes les clés de la même manière. Chaque clé de chaque liste sera rafraîchie une par une à partir d'un serveur de clés. Si vous utilisez gpg 2.1, il est possible de configurer un service TOR en oignon pour qu'il soit utilisé comme serveur de clés ! Voir la configuration pour un exemple.

Appelez cette commande chaque semaine depuis cron pour automatiser la vérification et faire envoyer les résultats aux administrateurs de liste respectifs :

schleuder refresh_keys

Les paquets disponibles pour Debian et CentOS installent tous deux une tâche cron hebdomadaire qui vérifie et actualise les clés. Les administrateurs de listes seront informés des problèmes ou des changements apportés à leur porte-clés.

Une commande de maintenance supplémentaire est disponible qui vous permet d'associer les abonnements à la clé qui leur correspond le mieux. Si aucune clé n'est attribuée, schleuder essaiera de sélectionner une clé dans le porte-clés de la liste qui correspond distinctement à l'adresse électronique de l'abonnement.

Cette fonction doit être utilisée avec précaution. Il est facile pour une personne malveillante (ou inexpérimentée) d'injecter des user-ID supplémentaires dans le porte-clés de la liste. Cela peut conduire à des situations dans lesquelles les gens reçoivent soudainement des courriels qui sont cryptés avec une clé qui ne leur appartient pas.

Il est préférable de ne pas exécuter cette commande automatiquement, et vous devez toujours examiner de près le résultat pour vérifier qu'il n'y a pas de conséquences involontaires.

schleuder pin_keys
