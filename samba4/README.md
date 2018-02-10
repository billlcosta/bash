
                            Implementação do Samba 4 - Domain Controller                        
                           ---------------------------------------------                        
                                                                                                
                                                                                                
Criado por.: pH                                                                                
Contato.: billlcosta@gmail.com                                                                 
Versão do script.: 1.0                                                                         
                                                                                                
Script desenvolvido para configuração do serviço Samba 4 (ultima versão stable) atuando como Domain    
Controller. Todo o procedimento será realizado de forma automatizada, sem interação.            
                                                                                                
Nota.: O script foi desenvolvido para ambientes Debian 8 e Cent'OS 7.3 e seus derivados        
                                                                                                
                                                                                                
                           Pacotes necessarios (serão instalados automaticamente)               
                           ------------------------------------------------------               
                                                                                                
                                                                                                
gcc libacl-devel libblkid-devel gnutls-devel wget perl ntp openldap-devel readline-devel       
python-devel gdb pkgconfig krb5-workstation zlib-devel setroubleshoot-server                   
setroubleshoot-plugins policycoreutils-python libsemanage-python setools-libs-python setools-libs      
popt-devel libpcap-devel sqlite-devel libidn-devel libxml2-devel libacl-devel libsepol-devel   
libattr-devel  keyutils-libs-devel cyrus-sasl-devel cups-devel                                 
                                                                                                
                                                                                                
                                       Requisitos de Instalação                                 
                                       ------------------------                                 
* Acesso a Internet                                                                            
* Desabilitar o SELinux                                                                        
                                                                                                
                                                                                                
                                               Instalação                                       
                                              ------------                                      
                                                                                                
                                                                                                
Debian 8 -  ./samba.sh debian                                                                  
Cent'OS 7.3 - ./samba.sh centos                                                                
                                
