#avec ce fichier on test l'aspect purement algorithmique de notre programme,
#ça seras plus simple pour le debuger

def convertire_IP2B_4(adr) :
    #adr étant une adresse ip sous forme de chaine de caractère
    #on la convertie en binaire sur 8 octets

    a =  ["0","0","0","0","0","0","0","0"]
    for i in range(8) :
        if adr%2 == 1 :
            a[7-i] = "1"
        adr = int(adr/2)
    return a



print(convertire_IP2B_4(128))