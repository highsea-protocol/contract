module toraii::groth16_vrf {
    use sui::groth16;
    use sui::event;
    use sui::dynamic_field;
    use sui::object::{Self, UID};
    use std::string;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
  
    /// Event on whether the proof is verified
    struct VerifiedEvent has copy, drop {
        root: string::String,
        block_num: string::String,
        is_verified: bool,
    }

    struct ReachMerkleTree has key, store{
        id: UID,

    }

    struct MerkleLeaf has key, store{
        id: UID,
        block_num: string::String,
        root_hash: string::String
    }

    fun init(ctx: &mut TxContext) {
        let root = ReachMerkleTree{id:object::new(ctx)};
        transfer::public_transfer(root, tx_context::sender(ctx));
    }

    public entry fun reach_status(merkle: &mut ReachMerkleTree, root: string::String, block_num: string::String, vk: vector<u8>, public_inputs_bytes: vector<u8>, proof_points_bytes: vector<u8>,ctx: &mut TxContext) : bool{
        let res = verify_proof(vk, public_inputs_bytes, proof_points_bytes);
        if (res) {
            let leaf = MerkleLeaf{ id: object::new(ctx), block_num: block_num, root_hash: root};
            // add status
            dynamic_field::add(&mut merkle.id, block_num, leaf);
            event::emit(VerifiedEvent {root: root, block_num: block_num, is_verified: res});
        } else {
            //for the convenience of expansion in the subsequent development process.
        };
        res
    }


    public fun verify_proof(vk: vector<u8>, public_inputs_bytes: vector<u8>, proof_points_bytes: vector<u8>) : bool{
        let pvk = groth16::prepare_verifying_key(&groth16::bn254(), &vk);
        let public_inputs = groth16::public_proof_inputs_from_bytes(public_inputs_bytes);
        let proof_points = groth16::proof_points_from_bytes(proof_points_bytes);
        let is_verified = groth16::verify_groth16_proof(&groth16::bn254(), &pvk, &public_inputs, &proof_points);
        is_verified
    }

}
