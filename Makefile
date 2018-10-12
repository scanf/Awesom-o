ELECTRON_PACKAGER ?=electron-packager
ELECTRON_INSTALLER_DMG ?=electron-installer-dmg
ELECTRON_INSTALLER_DEBIAN ?=electron-installer-debian
BACKGROUND_FILE ?=$(shell pwd)/assets/background.png
ICON_FILE ?=$(shell pwd)/assets/icons/mac/icon.icns
INSTALLER_ICON_FILE ?=$(shell pwd)/assets/icons/png/48x48.png
NEW_VERSION ?=$(shell git describe --tags --dirty)
REPOSITORY ?=scanf/awesom-o

install_deps:
	# Install the package helpers
	sudo npm install -g ${ELECTRON_PACKAGER} ${ELECTRON_INSTALLER_DMG} ${ELECTRON_INSTALLER_DEBIAN}
	# Install tool for uploading release binaries to GitHub
	pip install githubrelease
	# Install all of the app dependencies
	npm install .

run:
	electron .

clean:
	-rm -rvf Awesom-O* 
	-rm -rvf release-builds 
	-rm -rvf dist 
	-rm *.zip
	mkdir -pv dist

version:
	npm version -f ${NEW_VERSION}

macOS: 
	${ELECTRON_PACKAGER} --icon=${ICON_FILE} . Awesom-O --platform darwin --arch x64 --out .
	${ELECTRON_INSTALLER_DMG} --icon=${INSTALLER_ICON_FILE} \
	  --background=${BACKGROUND_FILE} Awesom-O-darwin-x64/Awesom-O.app/ Awesom-O

linux: 
	${ELECTRON_PACKAGER} . Awesom-O --platform linux --arch x64 --out .
	${ELECTRON_INSTALLER_DEBIAN} --src Awesom-O-linux-x64/ --dest . --arch amd64

windows: 
	${ELECTRON_PACKAGER} . Awesom-O --platform win32 --arch x64 --out .

all_platforms: clean linux windows macOS
	zip -9 dist/Awesom-O_${NEW_VERSION}_amd64.deb.zip Awesom-O_${NEW_VERSION}_amd64.deb
	zip -9 dist/Awesom-O.dmg.zip Awesom-O.dmg
	zip -r -9 dist/Awesom-O-win32-x64.zip Awesom-O-win32-x64

prerelease: version all_platforms
	git push github master
	githubrelease release ${REPOSITORY} create ${NEW_VERSION} --publish --name "Awesom-o ${NEW_VERSION}" "dist/*"
	git push github --tags

darwin:
	${ELECTRON_PACKAGER} . --overwrite --platform=darwin --arch=x64 --icon=${ICON_FILE} --prune=true --out .

purge:
	rm ~/twitch-bot-cache/data.json
