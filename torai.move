module toraii::torai {
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::coin::{Self, Coin, TreasuryCap};

    use std::string;
    use std::option;

    struct StakeEvent has copy, drop { token: string::String, amount: u64, ts_ms: u64, from: address }

    struct ToraiManCap has key,store{
        id: UID,
        treasury_cap: TreasuryCap<TORAI>
    }

    struct TORAI has drop {}

    fun init(witness: TORAI, ctx: &mut TxContext) {
        let (treasury_cap, coin_metadata) = coin::create_currency(
            witness,
            9,
            b"TORAI",
            b"Torai",
            b"Mint on Sui created by torai.money",
            option::none(),
            ctx
        );
        transfer::public_freeze_object(coin_metadata);
        transfer::public_transfer(ToraiManCap {id: object::new(ctx),treasury_cap}, tx_context::sender(ctx));
    }

    public entry fun mint(registry: &mut ToraiManCap, value: u64, recipient: address, ctx: &mut TxContext) {
        coin::mint_and_transfer(&mut registry.treasury_cap, value, recipient, ctx);
    }

    public entry fun transfer(obj: Coin<TORAI>, recipient: address) {
        transfer::public_transfer(obj, recipient)
    }
}

