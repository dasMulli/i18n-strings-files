fs = require('fs')
should = require('should')
i18nStringsFiles = require('../index')


fileTemp = __dirname + '/temp.strings'
fileTest = __dirname + '/test.strings'
fileEncoding = 'UTF-16'


checkValues = (data) ->
  data['test-normal'].should.equal("Test normal")
  data['test-chars'].should.equal("Olvidé mi contraseña")
  data['test-new-lines'].should.equal("Test\nNew\nLines")
  data['test-quotes'].should.equal("\"Test quote\"")
  data['test-spacing'].should.equal("Test spacing")
  data['test \n edge" = '].should.equal("Test edge")


describe 'Sync: Reading file into object', ->
  it 'should populate object properties with values', ->
    data = i18nStringsFiles.readFileSync(fileTest, fileEncoding)
    checkValues(data)


describe 'Sync: Read, compile, parse', ->
  it 'should populate object properties with values before and after', ->
    data = i18nStringsFiles.readFileSync(fileTest, fileEncoding)
    checkValues(data)
    str = i18nStringsFiles.compile(data)
    data = i18nStringsFiles.parse(str)
    checkValues(data)


describe 'Sync: Read, write, read', ->
  it 'should populate object properties with values before and after', ->
    data = i18nStringsFiles.readFileSync(fileTest, fileEncoding)
    checkValues(data)
    i18nStringsFiles.writeFileSync(fileTemp, data, fileEncoding)
    data = i18nStringsFiles.readFileSync(fileTemp, fileEncoding)
    checkValues(data)
    fs.unlinkSync(fileTemp)


describe 'Async: Reading file into object', ->
  it 'should populate object properties with values', (done) ->
    i18nStringsFiles.readFile fileTest, fileEncoding, (err, data) ->
      checkValues(data)
      done()


describe 'Async: Read, write, read', ->
  it 'should populate object properties with values before and after', (done) ->
    i18nStringsFiles.readFile fileTest, fileEncoding, (err, data) ->
      checkValues(data)
      i18nStringsFiles.writeFile fileTemp, data, fileEncoding, (err) ->
        i18nStringsFiles.readFile fileTemp, fileEncoding, (err, data) ->
          checkValues(data)
          fs.unlinkSync(fileTemp)
          done()


describe 'Async: Read, write, read (no encoding param)', ->
  it 'should populate object properties with values before and after', (done) ->
    i18nStringsFiles.readFile fileTest, (err, data) ->
      checkValues(data)
      i18nStringsFiles.writeFile fileTemp, data, (err) ->
        i18nStringsFiles.readFile fileTemp, (err, data) ->
          checkValues(data)
          fs.unlinkSync(fileTemp)
          done()

describe 'Compilation', ->
  it 'shall replace windows-style CRLF newlines with LF(mac/unix) newlines', (done) ->
    # Given: a dictionary containing a value string with CRLF newlines
    crlfDict = { aKey: 'Test\r\nNew\r\nLines' };

    # When: the dictionary is compiled to strings file format
    stringsFileContent = i18nStringsFiles.compile(crlfDict);

    # Then: the resulting content shall match the content crated for LF-only source
    lfDict = { aKey: 'Test\nNew\nLines' };
    stringsFileContent.should.equal(i18nStringsFiles.compile(lfDict));

    done()