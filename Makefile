#
# Copyright (c) Members of the EGEE Collaboration. 2004-2010.
# See http://www.eu-egee.org/partners/ for details on the copyright holders. 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#
# RPM/ETICS
#
name = argus-pep-api-c
version = 2.2.0
release = 1

dist_url = https://github.com/downloads/argus-authz/argus-pep-api-c/$(name)-$(version).tar.gz

debbuild_dir = $(CURDIR)/debbuild
tmp_dir=$(CURDIR)/tmp
tgz_dir=$(CURDIR)/tgz
rpm_dir=$(CURDIR)/RPMS
deb_dir=$(CURDIR)/debs

all: deb-src

clean:
	@echo "Cleaning..."
	rm -rf $(debbuild_dir) *.deb

pre_debbuild:
	@echo "Prepare for Debian building in $(debbuild_dir)"
	mkdir -p $(debbuild_dir)
	test -f $(debbuild_dir)/$(name)_$(version).orig.tar.gz || wget -O $(debbuild_dir)/$(name)_$(version).orig.tar.gz $(dist_url)
	tar -C $(debbuild_dir) -xzf $(debbuild_dir)/$(name)_$(version).orig.tar.gz


deb: pre_debbuild
	@echo "Building Debian package in $(debbuild_dir)"
	cd $(debbuild_dir)/$(name)-$(version) && debuild -us -uc 


deb-src: pre_debbuild
	@echo "Building Debian source package in $(debbuild_dir)"
	cd $(debbuild_dir) && dpkg-source -b $(name)-$(version)



etics:
	@echo "Publish SRPM/RPM/Debian/tarball"
	mkdir -p $(rpm_dir) $(tgz_dir) $(deb_dir)
	test ! -f $(name)-$(version).src.tar.gz || cp -v $(name)-$(version).src.tar.gz $(tgz_dir)
	test ! -f $(rpmbuild_dir)/SRPMS/$(name)-$(version)-*.src.rpm || cp -v $(rpmbuild_dir)/SRPMS/$(name)-$(version)-*.src.rpm $(rpm_dir)
	if [ -f $(rpmbuild_dir)/RPMS/*/$(name)-$(version)-*.rpm ] ; then \
		cp -v $(rpmbuild_dir)/RPMS/*/$(name)-$(version)-*.rpm $(rpm_dir) ; \
		test ! -d $(tmp_dir) || rm -fr $(tmp_dir) ; \
		mkdir -p $(tmp_dir) ; \
		cd $(tmp_dir) ; \
		rpm2cpio $(rpmbuild_dir)/RPMS/*/$(name)-$(version)-*.rpm | cpio -idm ; \
		tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz * ; \
		mv -v $(name)-$(version).tar.gz $(tgz_dir) ; \
		rm -fr $(tmp_dir) ; \
	fi
	test ! -f $(debbuild_dir)/$(name)_$(version)-*.dsc || cp -v $(debbuild_dir)/$(name)_$(version)-*.dsc $(deb_dir)
	test ! -f $(debbuild_dir)/$(name)_$(version)-*.debian.tar.gz || cp -v $(debbuild_dir)/$(name)_$(version)-*.debian.tar.gz $(deb_dir)
	test ! -f $(debbuild_dir)/$(name)_$(version).orig.tar.gz || cp -v $(debbuild_dir)/$(name)_$(version).orig.tar.gz $(deb_dir)
	if [ -f $(debbuild_dir)/$(deb_name)_$(version)-*.deb ] ; then \
		cp -v $(debbuild_dir)/$(deb_name)_$(version)-*.deb $(deb_dir) ; \
		test ! -d $(tmp_dir) || rm -fr $(tmp_dir) ; \
		mkdir -p $(tmp_dir) ; \
		dpkg -x $(debbuild_dir)/$(deb_name)_$(version)-*.deb $(tmp_dir) ; \
		cd $(tmp_dir) ; \
		tar -C $(tmp_dir) -czf $(name)-$(version).tar.gz * ; \
		mv -v $(name)-$(version).tar.gz $(tgz_dir) ; \
		rm -fr $(tmp_dir) ; \
	fi

