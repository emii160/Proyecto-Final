# Proyecto-Final
Imagen1 comandos:
rpm --version: Ese comando muestra la versión de RPM instalada
rpmbuild --version: Ese comando muestra la versión rpmbuild, la cual sirve para compilar paquetes RPM.
createrepo_c  --version: Ese comando verifica la instalación de createrepo_c, la cual permite crear repositorios locales de paquetes RPM. 


Imagen 2 comandos:
rbenv --version: Verifica que rbenv está instalado correctamente.
ruby --version: Verifica que ruby está instalado correctamente.
rbenv versions: Hace una lista de las versiones de Ruby disponibles 
ls /usr/local/rbenv/plugins/ruby-build: Ese comando confirma que ruby-build está correctamente instalado y listo para instalar versiones de Ruby.

Imagen3 comandos:
node -v: Muestra la versión de Node.js instalada.
npm -v: Muestra la versión de npm instalada junto con Node.js
yarn -v: Muestra la versión instalada de Yarn. 
nvm list: Confirma que nvm tenga ambas versiones

Imagen4 comandos:
python3 --version: Verifica la versión de Python
python3 -m pip --version: Comprueba el gestor de paquetes
python3 -m pip show setuptools: Confirma que setuptools está instalado
python3 -m venv test-env: Crea el entorno virtual
source test-env/bin/activate: activa el entorno virtual
pip install requests: instala el paquete para el entorno
Luego del paquete instalado se coloca esto: python -c "import requests; print(requests.__version__)"
Para salirse del entorno virtual usamos:  deactivate

