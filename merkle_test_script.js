// run `node merkle_test_script.js` in your console to run this

const { MerkleTree } = require('merkletreejs')
const keccak256 = require('keccak256')

const whitelist = [
    '0x717593345E361D1345E07706dAFD61c990Cc9580',
    '0x26AA77E25557f0785e4DB6753d56300Dd90f2B60',
    '0xa4Cd575392CaB84a804cdcef3C3fDcE134B451ed',
]

// const notIn = '0xf3bFE9629DC27282ea2BD663bC521F3b89c4617d';

const leaves = whitelist.map(addr => keccak256(addr))
console.log(leaves)
const merkleTree = new MerkleTree(leaves, keccak256, { sortPairs: true })
const rootHash = merkleTree.getRoot()

console.log('merkle tree is', merkleTree)
console.log('The root hash is', rootHash.toString('hex'))
console.log('')
console.log('Whitelist Merkle Treen\n', merkleTree.toString())

const address = whitelist[0]
    // const address = notIn

const hexProof = merkleTree.getHexProof(keccak256(address))
console.log('proof:', hexProof)

const leaf = keccak256(address)
const check = merkleTree.verify(hexProof, leaf, rootHash)
console.log('Address in whitelist:', check)