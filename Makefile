DRAFT:=lamps-rfc7030-csrattrs
VERSION:=$(shell ./getver ${DRAFT}.mkd )
EXAMPLES=example01.acp.csrattr.dump
EXAMPLES+=example01.acp.csrattr.base64

${DRAFT}-${VERSION}.txt: ${DRAFT}.txt
	cp ${DRAFT}.txt ${DRAFT}-${VERSION}.txt
	: git add ${DRAFT}-${VERSION}.txt ${DRAFT}.txt

%.xml: %.mkd ${EXAMPLES}
	kramdown-rfc2629 --v3 ${DRAFT}.mkd >${DRAFT}.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --v2v3 ${DRAFT}.xml
	mv ${DRAFT}.v2v3.xml ${DRAFT}.xml

%.txt: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --text -o $@ $?

%.html: %.xml
	unset DISPLAY; XML_LIBRARY=$(XML_LIBRARY):./src xml2rfc --html -o $@ $?

submit: ${DRAFT}.xml
	curl -s -F "user=mcr+ietf@sandelman.ca" ${REPLACES} -F "xml=@${DRAFT}.xml" https://datatracker.ietf.org/api/submission | jq

version:
	echo Version: ${VERSION}

clean:
	-rm -f ${DRAFT}.xml
	-rm csr.der csr.pem

# this data is from ANIMAgus-Minerva's Fountain implementation, dumped by tests as
#    tmp/csr_bulb1.csrattr.der
example01.acp.csrattr.dump: example01.acp.csrattr.der
	dumpasn1 -il example01.acp.csrattr.der >example01.acp.csrattr.dump

example01.acp.csrattr.base64: example01.acp.csrattr.der
	base64 example01.acp.csrattr.der >example01.acp.csrattr.b64

.PRECIOUS: ${DRAFT}.xml
