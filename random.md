- Devise per gestire l'autenticazione https://github.com/heartcombo/devise
- rolify https://github.com/RolifyCommunity/rolify
- mysql2 (gemma per mysql2)



COMANDI UTILI:
- rails server (avvio l'app)
- bundle install e bundle update (dipendenze)
- esecuzione migrazioni: rails db:migrate


COSE FATTE:
1) Creazione del db tramite migrazioni 
    - rails generate model User name:string surname:string email:string phone:string date_of_birth:date address:string cap:string province:string state:string password:string
    - rails generate model Event name:string beginning_time:time beginning_date:date ending_time:time ending_date:date max_participants:integer address:string cap:string province:string state:string user:references
    - rails generate model Subscription user:references event:references subscription_time:time subscription_date:date
    -> rails db:migrate

