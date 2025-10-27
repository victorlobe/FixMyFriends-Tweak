ARCHS = armv7 arm64
TARGET := iphone:7.1


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = FixMyFriends

FixMyFriends_FILES = Tweak.x
FixMyFriends_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk


.NOTPARALLEL: after-stage after-package dev-pipeline release-pipeline
MAKEFLAGS += -j1

ifeq ($(FINALPACKAGE),)
after-package:: dev-pipeline
else
after-package:: release-pipeline
endif

.PHONY: dev-pipeline release-pipeline

dev-pipeline:
	# Mirror progress to stderr (unbuffered) so you see something even if stdout is grouped.
	@echo "[📌] Starting Build on DEV Pipeline" 1>&2
	# Run everything under a PTY so child tools line-buffer their output.
	@script -q /dev/null /bin/bash -lc 'set -euo pipefail; \
		echo "[ℹ️ ] Locating latest .deb…"; \
		DEB="$$(ls -t "$(THEOS_PACKAGE_DIR)"/*.deb | head -1)"; \
		if [ -z "$$DEB" ] || [ ! -f "$$DEB" ]; then echo "[❌] No .deb found in $(THEOS_PACKAGE_DIR)"; exit 1; fi; \
		echo "[ℹ️ ] Found: $$DEB"; \
		BASE="$$(basename "$$DEB" .deb)"; TMP="$${BASE#*_}"; VERSION="$${TMP%_*}"; \
		echo "[ℹ️ ] Version: $$VERSION"; \
		echo "[📦] Git commit…"; \
		git add -A; \
		if git commit -m "Build $$VERSION"; then echo "[✅] Commit successful"; else echo "[⚠️ ] Nothing to commit"; fi; \
		DEST="/Volumes/victor/Sites/repo-dev/debs"; \
		echo "[📂] Copy .deb → $$DEST"; \
		mkdir -p "$$DEST"; cp -v "$$DEB" "$$DEST/"; \
		echo "[⚙️ ] Run repo update…"; \
		cd /Volumes/victor/Sites/repo-dev; \
		if [ -x ./Update.sh ]; then ./Update.sh; \
		elif [ -x ./update.sh ]; then ./update.sh; \
		elif [ -f ./Update.sh ]; then /bin/bash ./Update.sh; \
		elif [ -f ./update.sh ]; then /bin/bash ./update.sh; \
		else echo "[⚠️ ] Warning: update script not found"; fi; \
		echo "[✅] Repo update finished"; \
		MSG="Built $$VERSION and updated repo"; \
		echo "[🔔] Notifying macOS…"; \
		/usr/bin/osascript -e "display notification \"$$MSG\" with title \"FixMyFriends Build\" subtitle \"Deployment complete\"" \
		&& echo "[✅] Notification sent" || echo "[⚠️ ] Could not display notification"'

release-pipeline:
	@echo "[📌] Starting Build on RELEASE Pipeline" 1>&2
	@script -q /dev/null /bin/bash -lc 'set -euo pipefail; \
	DEB="$$(ls -t "$(THEOS_PACKAGE_DIR)"/*.deb | head -1)"; \
	if [ -z "$$DEB" ] || [ ! -f "$$DEB" ]; then echo "[❌] No .deb found in $(THEOS_PACKAGE_DIR)"; exit 1; fi; \
	BASE="$$(basename "$$DEB" .deb)"; TMP="$${BASE#*_}"; VER="$${TMP%_*}"; \
	echo "[🚀 RELEASE] Built $$DEB (Version: $$VER)"; \
	echo "[ℹ️ ] (Release mode: no deploy; just committing)"; \
	git add -A || true; \
	if git commit -m "Release $$VER"; then \
		echo "[✅] Git commit: Release $$VER"; \
	else \
		echo "[⚠️ ] Nothing to commit"; \
	fi;'
	