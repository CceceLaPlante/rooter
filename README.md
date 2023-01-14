README.md 
_________________
# Router : utilisation 
- Choix de la structure d'implémentation du cache : 
	- 
	-  lancer cache_la pour un cache implémenté en arbre
	-  lancer cache_ll pour un cache implémenté en liste chaînée

- listes des commandes l'ors de l'appel du programme : 
	- 
	- `-c <taille>` définir la taille du cache, il seras régulièrement nettoyé selon la **politique** pour respecter cette limite, par défaut : 10
	- `-P FIFO|LRU|LFU` définir la **politique** du cache : 
		- `FIFO` First in First out, i.e : supprimer le dernier élément ajouté dans le cache (politique par défaut)
		- `LRU` Last Recently Used i.e : supprimer l'élément non utilisé depuis le plus longtemps.
		- `LFU` Last Frequently Used i.e : supprimer l'élément le moins utilisé.

	
	- `-s` afficher les statistiques (option par défaut)
	- `-S` ne pas afficher les statistiques
	- `-t <fichier>`  Définir le nom du fichier contenant les **tables de routages**, par défaut : `table.txt`
	- `-p <fichier>` Définir le nom du fichier contenant les paquets à router. Par défaut : `paquets.txt`
	- `-r <fichier>` Définir le nom du fichier contenant les résultats. Par défaut : `restultats.txt`

	-  exemple d'utilisation : `cache_la -s -c 10 -P LRU` utiliseras un router avec un cache en arborescence, suivant une politique LRU affichant les statistiques, et avec une taille maximal de 10 pour générer le fichier restultats.txt à partir de paquets.txt et table.txt.
- Format de table.txt
	- 
	```Table.txt
	<ADRESSE IP1> <MASQUE1> <INTERFACE1>
	<ADRESSE IP2> <MASQUE2> <INTERFACE2>
	<ADRESSE IP2> <MASQUE2> <INTERFACE2>
	<ADRESSE IP2> <MASQUE2> <INTERFACE2>
	etc...
	```
	les adresses ip sont sous la forme X.X.X.X, où 0 < X < 256 les masques sous la forme X.X.X.X, et les interfaces des chaînes de charactères.
- Format de paquets.txt
	- 
	```paquets.txt
	<ADRESSE IP | commande>
	<ADRESSE IP | commande>
	<ADRESSE IP | commande>
	etc...
	<ADRESSE IP | commande>
	fin
	```
	ce fichier finis forcément par le mot clé `fin`
	adresse ip est du même type que table.txt, par ailleur, commande est : 
	- `fin` marque la fin du fichier.
	- `cache` affiche le cache
	- `table` affiche la table de routage
- Format de resultats.txt
	- 
	```resultats.txt
	<ADRESSE IP> <interface>
	<ADRESSE IP> <interface>
	<ADRESSE IP> <interface>
	<ADRESSE IP> <interface>
	<ADRESSE IP> <interface>
	```
	les adresse IP sont dans le mêmes ordre que dans `paquets.txt`, de plus, ce fichier n'est pas à créer, il seras créé par le programme, ou écrasé si il éxistait déjà.

