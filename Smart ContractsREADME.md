**This is a NFT contract built on OpenZeppelin's ERC721 standard with royalty support (ERC2981)**

**Key Features:**

NFT Standard: ERC721 with metadata evolution.

Ownership: Only the owner can mint and update URIs.

Supply Limit: Max 1,000 tokens (MAX_SUPPLY).

Evolution Mechanism:

Tokens "evolve" after 5 transfers (EVOLUTION_THRESHOLD).
Evolved tokens use a different baseURI (evolvedBaseURI).

Royalties: 10% (1000 bps) set to the deployer via ERC2981.

**Core Functions:**

**Minting:**

mint(): Single NFT minting (owner-only)

batchMint(): Mint multiple NFTs at once

**Transfers:**

_update(): Tracks transfers; triggers evolution after 5 transfers.

**Metadata:**

tokenURI(): Returns dynamic URI (initial or evolved)

**Admin:**

setInitialBaseURI()/setEvolvedBaseURI(): Update metadata URIs.

**Events:**

Minted: Emitted on new NFT creation.

MetadataEvolved: Emitted when a token evolves.

**Security:**

Uses OpenZeppelin’s Ownable, ERC721, and ERC2981 for security and standards compliance.

Safe minting (_safeMint) prevents accidental loss.
