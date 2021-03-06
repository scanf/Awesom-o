ELECTRON ?=node_modules/.bin/electron
ELECTRON_PACKAGER ?=electron-packager
ELECTRON_INSTALLER_DMG ?=electron-installer-dmg
ELECTRON_INSTALLER_DEBIAN ?=electron-installer-debian
ELECTRON_BUILDER ?=electron-builder
BACKGROUND_FILE ?=$(shell pwd)/assets/background.png
MAC_ICON_FILE ?=$(shell pwd)/assets/icons/mac/icon.icns
LINUX_ICON_FILE ?=$(shell pwd)/assets/icons/png/512x512.png
WINDOWS_ICON_FILE ?=assets/icons/win/icon.ico
INSTALLER_MAC_ICON_FILE ?=$(shell pwd)/assets/icons/png/48x48.png
NEW_VERSION ?=$(shell git describe --tags --dirty)
REPOSITORY ?=scanf/awesom-o
BUILD_DIR ?=builds
DIST_DIR ?=githubrelease
IGNORE_STUFF ?="(\.git|${BUILD_DIR}|${DIST_DIR})"

install_deps:
	# Install the package helpers
	sudo npm install -g ${ELECTRON_PACKAGER} ${ELECTRON_INSTALLER_DMG} ${ELECTRON_INSTALLER_DEBIAN} ${ELECTRON_BUILDER}
	# Install tool for uploading release binaries to GitHub
	pip install githubrelease setuptools
	# Install all of the app dependencies
	npm install .

run:
	${ELECTRON} .

clean:
	find . -name "*.DS_Store" -type f -delete
	-rm -rvf ${DIST_DIR} 
	-rm -rvf ${BUILD_DIR}
	mkdir -pv ${DIST_DIR} 
	mkdir -pv ${BUILD_DIR}

version:
	npm version -f ${NEW_VERSION}

mac%:
	${ELECTRON_PACKAGER} --ignore=${IGNORE_STUFF} --overwrite --asar --prune=true \
	  --icon=${MAC_ICON_FILE} . Awesom-O --platform darwin --arch x64 --out ${BUILD_DIR}
	${ELECTRON_INSTALLER_DMG} --icon=${INSTALLER_MAC_ICON_FILE} \
	  --background=${BACKGROUND_FILE} ${BUILD_DIR}/Awesom-O-darwin-x64/Awesom-O.app/ ${BUILD_DIR}/Awesom-O

linux: 
	${ELECTRON_PACKAGER} --ignore=${IGNORE_STUFF} --overwrite --asar --prune=true \
	  --icon=${LINUX_ICON_FILE} . Awesom-O --platform linux --arch x64 --out ${BUILD_DIR}
	${ELECTRON_INSTALLER_DEBIAN} --src ${BUILD_DIR}/Awesom-O-linux-x64/ --dest ${BUILD_DIR} --arch amd64


appimage:
	${ELECTRON_PACKAGER} --ignore=${IGNORE_STUFF} --overwrite --asar --prune=true \
	  --icon=${ICON_FILE} . Awesom-O --platform linux --arch x64 --out ${BUILD_DIR}
	${ELECTRON_BUILDER} -l AppImage

windows: 
	${ELECTRON_PACKAGER} --ignore=${IGNORE_STUFF} --overwrite --asar --prune=true \
	  --icon=${WINDOWS_ICON_FILE} . Awesom-O --platform win32 --arch x64 --out ${BUILD_DIR}

all_platforms: clean linux windows macOS appimage
	zip -9 -j ${DIST_DIR}/Awesom-O-${NEW_VERSION}-x86_64.AppImage.zip dist/Awesom-O-${NEW_VERSION}-x86_64.AppImage
	zip -9 -j ${DIST_DIR}/Awesom-O_${NEW_VERSION}_amd64.deb.zip ${BUILD_DIR}/Awesom-O_${NEW_VERSION}_amd64.deb
	zip -9 -j ${DIST_DIR}/Awesom-O.dmg.zip ${BUILD_DIR}/Awesom-O.dmg
	zip -r -j -9 ${DIST_DIR}/Awesom-O-win32-x64.zip ${BUILD_DIR}/Awesom-O-win32-x64

# Usage: NEW_VERSION=<semver> make prerelease
prerelease: version all_platforms
	git push github master
	githubrelease release ${REPOSITORY} create ${NEW_VERSION} --publish --name "Awesom-o ${NEW_VERSION}" "${DIST_DIR}/*"
	git push github --tags

purge:
	rm ~/twitch-bot-cache/data.json
