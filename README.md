# NETWORKKIT-P
Liste de commandes sur la réseautique écrit en Pascal (Turbo Pascal ou Free Pascal).

<h2>Liste des fichiers</h2>

Voici la liste des différents fichiers proposés dans NETWORKKIT-P :

<table>
	<tr>
		<th>Nom</th>
		<th>Description</th>	
	</tr>
	<tr>
		<td><b>ACONNECT.PAS</b></td>
		<td>Cette commande permet de lancer le gestionnaire de connexions ALSA MIDI.</td>
	</tr>
	<tr>
		<td><b>ARP.PAS</b></td>
		<td>Cette commande permet d'effectuer la manipulation de la table ARP (<i>Address Resolution Protocol</i>).</td>
	</tr>
	<tr>
		<td><b>CURL.PAS</b></td>
		<td>Cette commande permet de lire le contenu d'un URL et de le retourner dans la console.</td>
	</tr>
	<tr>
		<td><b>DNSQUERY.PAS</b></td>
		<td>Cette commande permet de lancer l'outil de requête DNS.</td>
	</tr>
	<tr>
		<td><b>ELM.PAS</b></td>
		<td>Cette commande permet de lancer le ELM (Electronic Mail Reader).</td>
	</tr>
	<tr>
		<td><b>FINDSMB.PAS</b></td>
		<td>Cette commande permet de rechercher des serveurs SMB/CIFS dans le réseau.</td>
	</tr>
	<tr>
		<td><b>FINGER.PAS</b></td>
		<td>Cette commande permet d'afficher des informations sur les utilisateurs connectés ou à distance.</td>
	</tr>
	<tr>
		<td><b>FTP.PAS</b></td>
		<td>Cette commande permet de lancer un client FTP en ligne de commande.</td>
	</tr>
	<tr>
		<td><b>GOPHER.PAS</b></td>
		<td>Cette commande permet de lancer un client Gopher en ligne de commande.</td>
	</tr>
	<tr>
		<td><b>HOSTNAME.PAS</b></td>
		<td>Cette commande permet de retourner le nom de l'hôte.</td>
	</tr>
	<tr>
		<td><b>IFCONFIG.PAS</b></td>
		<td>Cette commande permet d''effectuer la configuration et l'affichage des interfaces réseau.</td>
	</tr>
	<tr>
		<td><b>IFTOP.PAS</b></td>
		<td>Cette commande permet de lancer l'interface de surveillance d'utilisation de la bande passante.</td>
	</tr>
	<tr>
		<td><b>INEWS.PAS</b></td>
		<td>Cette commande permet de publier des articles d''actualité sur un serveur NNTP.</td>
	</tr>
	<tr>
		<td><b>IP.PAS</b></td>
		<td>Cette commande permet d''afficher et manipuler la configuration réseau.</td>
	</tr>
	<tr>
		<td><b>IPCONFIG.PAS</b></td>
		<td>Cette commande permet d'afficher l'adresse IP de la machine local.</td>
	</tr>
	<tr>
		<td><b>IPMADDR.PAS</b></td>
		<td>Cette commande permet d'effectuer la gestion des adresses de multidiffusion IP.</td>
	</tr>
	<tr>
		<td><b>IPTRAF.PAS</b></td>
		<td>Cette commande permet de lancer l'utilitaire de statistiques réseau en console.</td>
	</tr>
	<tr>
		<td><b>IPTUNNEL.PAS</b></td>
		<td>Cette commande permet d'effectuer la gestion des tunnels IP.</td>
	</tr>tr
	<tr>
		<td><b>ISEMAIL.PAS</b></td>
		<td>Cette commande permet de vérifier si le courriel est un courriel valide.</td>
	</tr>
	<tr>
		<td><b>NE2000.PAS</b></td>
		<td>Cette commande permet de lancer un pilote de paquet pour cartes Ethernet NE2000 compatible ISA.</td>
	</tr>
	<tr>
		<td><b>NETBIOS.PAS</b></td>
		<td>Cette commande permet d'afficher des informations NetBIOS.</td>
	</tr>
	<tr>
		<td><b>WHOAMI.PAS</b></td>
		<td>Cette commande permet de retourner l'utilisateur connecté.</td>
	</tr>
	<tr>
		<td><b>WHOIS.PAS</b></td>
		<td>Cette commande permet de rechercher l'organisme associé avec un IP en se basant sur un dictionnaire locale hors ligne.</td>
	</tr>	
</table>

<h2>Compilation</h2>
	
Les fichiers Pascal n'ont aucune dépendances, il suffit de télécharger le fichier désiré et de le compiler avec Free Pascal avec la syntaxe de commande  :

<pre><b>fpc</b> <i>LEFICHIER.PAS</i></pre>
	
Sinon, vous pouvez également le compiler avec le Turbo Pascal à l'aide de la syntaxe de commande suivante :	

<pre><b>tpc</b> <i>LEFICHIER.PAS</i></pre>
	
Par exemple, si vous voulez compiler ISEMAIL.PAS, vous devrez tapez la commande suivante :

<pre><b>fpc</b> ISEMAIL.PAS</pre>

<h3>Remarque</h3>
<ul>
	<li>A partir de la version 1.01 de la commande IPCONFIG, il est possible d'utiliser la commande en Turbo Pascal si le système d'exploitation supporte WATTCP ou NetBIOS.</li>
</ul>

<h2>Licence</h2>
<ul>
 <li>Le code source est publié sous la licence <a href="https://github.com/gladir/NETWORKKIT-P/blob/main/LICENSE">MIT</a>.</li>
 <li>Le paquet original est publié sous la licence <a href="https://github.com/gladir/NETWORKKIT-P/blob/main/LICENSE">MIT</a>.</li>
</ul>

