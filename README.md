# Ruby_On_Rails_Web_App

# Consegna Progetto
Prenotazione Eventi
Sviluppare un’applicazione Web che permetta ad utenti ed organizzatori di gestire la
prenotazione ad eventi.
L’applicazione dovrà implementare le seguenti feature:
● Registrazione di utenti
● Registrazione di organizzatori
● Permettere ad organizzatori di creare eventi caratterizzati da
    ○ Nome
    ○ Orario Inizio (anche data)
    ○ Orario Fine (anche data)
    ○ Luogo evento
    ○ Posizione geografica
    ○ Massimo numero di partecipanti

● Gli utenti invece saranno in grado di
    ○ Ricercare eventi (anche filtrando per posizione geografica)
    ○ Registrarsi e deregistrarsi ad eventi
● impedire ad utenti di registrarsi ad un evento se concomitante ad un altro ai
quali sono già iscritti.
● Permettere agli organizzatori di consultare la lista dei partecipanti ai propri
eventi ed eventualmente rimuovere utenti iscritti indesiderati dai propri eventi

Inoltre, l’applicazione dovrà implementare un sistema di notifiche per permettere ad
utenti registrati ad un evento se esso ha avuto variazioni, se esso viene annullato
dall’organizzatore, o se essi sono stati rimossi. Allo stesso modo, gli organizzatori
dovranno essere notificati in caso di vari scenari legati ai loro eventi (es massima
capienza raggiunta).

Per gruppi più numerosi:
● Possibilità da parte degli organizzatori di inviare messaggi (tramite notifica) a
tutti gli iscritti ad un proprio evento
● Possibilità degli organizzatori di gestire una blacklist per utenti la quale
impedirà agli utenti bannati di iscriversi agli eventi da loro creati
● Sistema di chat tra organizzatori ed utenti