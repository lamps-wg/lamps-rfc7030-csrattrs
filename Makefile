DRAFT:=lamps-rfc7030-csrattrs
VERSION:=$(shell ./getver ${DRAFT}.mkd )
EXAMPLES=
EXAMPLES+=examples/realistic-acp.csrattr.b64
EXAMPLES+=examples/realistic-acp.csrattr.dump
EXAMPLES+=examples/rfc7030-example01.csrattr.b64
EXAMPLES+=examples/rfc7030-example01.csrattr.dump
EXAMPLES+=examples/potato-example.csrattr.b64
EXAMPLES+=examples/potato-example.csrattr.dump
EXAMPLES+=examples/harkins01.csrattr.b64
EXAMPLES+=examples/harkins01.csrattr.dump
EXAMPLES+=examples/harkins02.csrattr.b64
EXAMPLES+=examples/harkins02.csrattr.dump
EXAMPLES+=examples/harkins03.csrattr.b64
EXAMPLES+=examples/harkins03.csrattr.dump
# EXAMPLES+=examples/corey-example.csrattr.dump

.phony: default
default: ${DRAFT}-${VERSION}.txt

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.mkd ${EXAMPLES}
	kramdown-rfc2629 --v3 ${DRAFT}.mkd >${DRAFT}.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --v2v3 ${DRAFT}.xml
	mv ${DRAFT}.v2v3.xml ${DRAFT}.xml

%.pdf: %.xml
	xml2rfc --pdf -o $@ $?

%.txt: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --text -o $@ $?

%.html: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --html -o $@ $?

submit: ${DRAFT}.xml
	curl --http1.1 -s -F "user=mcr+ietf@sandelman.ca" ${REPLACES} -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submission | jq

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}.xml

examples: ${EXAMPLES}

# this data is from ANIMAgus-Minerva's Fountain implementation, dumped by tests as
#    tmp/csr_bulb1.csrattr.der
# ideally, use dumpasn1 from the git@github.com:mcr/dumpasn1.git
%.dump: %.der
	dumpasn1 -htl -w50 -B24 $< | sed -e's/ *$$//' >$@

%.b64:  %.der
	base64 --wrap=48 $< > $@

update:
	mkdir -p examples
	cp /corp/projects/pandora/fountain/tmp/realisticACP.der examples/realistic-acp.csrattr.der
	cp /corp/projects/pandora/fountain/tmp/potato-csr.der   examples/potato-example.csrattr.der
	cp /corp/projects/pandora/fountain/spec/files/csrattr_example02.der examples/corey-example.csrattr.der

.PRECIOUS: ${DRAFT}.xml

