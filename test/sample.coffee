describe 'Array', ->
  describe '#indexOf', ->
    it 'returns -1 when not present', ->
      [1, 2, 3].indexOf(2).should.equal -1
