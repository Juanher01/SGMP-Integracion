| EVIDENCIA                     |        Qué demuestra                                             |  Por qué importa                                    |
|-------------------------------|------------------------------------------------------------------|------------------------------------------------------|
|01-contenedores-dev-test.png   |Que existen y están ejecutándose los dos contenedores PostgreSQL  | Demuestra que DEV y TEST pueden coexistir            |
|02-volumenes-postgresql.png    | Que cada ambiente tiene almacenamiento persistente independiente | Demuestra que DEV y TEST no comparten datos          |
|03-postgresql-dev-healthy.png  |Que PostgreSQL DEV pasó su healthcheck                            | Demuestra que DEV está listo para aceptar conexiones |
|04-postgresql-test-healthy.png |Que PostgreSQL TEST pasó su healthcheck                           | Demuestra que TEST también está listo y aislado      |