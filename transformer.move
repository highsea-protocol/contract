module toraii::transformer {
    use sui::tx_context::{Self,TxContext};
    use sui::event::emit;
    use sui::transfer;
    use sui::clock::{Self, Clock};
    use sui::coin::{Self,Coin};
    use sui::balance::{Self};
    use sui::sui::{Self,SUI};

    use toraii::torai::{TORAI};
    use toraii::set::Set;
    

    struct ToraiStakeEvent has copy, drop {amount: u64, ts_ms: u64, from: address }
    struct ToraiUnStakeEvent has copy, drop {amount: u64, ts_ms: u64, to: address }
    struct BuyToraiEvent has copy, drop { amount: u64, ts_ms: u64, to: address }

    public entry fun buy_torai(
        obj: Coin<SUI>,
        recipient: address,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let ts_ms = clock::timestamp_ms(clock);
        let amount_balance = coin::balance(&obj);
        let amount = balance::value(amount_balance);
        sui::transfer(obj, recipient);
        emit(BuyToraiEvent { amount, ts_ms, to: tx_context::sender(ctx) });
    }

    public entry fun deposit_to_reach(
        obj: Coin<TORAI>,
        recipient: address,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let ts_ms = clock::timestamp_ms(clock);
        let amount_balance = coin::balance(&obj);
        let amount = balance::value(amount_balance);
        transfer::public_transfer(obj, recipient);
        emit(ToraiStakeEvent { amount, ts_ms, from: tx_context::sender(ctx) });
    }

    public entry fun from_reach(
        obj: Coin<TORAI>,
        recipient: address,
        clock: &Clock
    ) {
        let ts_ms = clock::timestamp_ms(clock);
        let amount_balance = coin::balance(&obj);
        let amount = balance::value(amount_balance);
        transfer::public_transfer(obj, recipient);
        emit(ToraiUnStakeEvent {amount, ts_ms, to: recipient });
    }

    public entry fun unlock(
        obj: Set,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        toraii::set::burn(obj, clock, ctx);
    }

    /**
     * Transfer `set` to `recipient`
     * Note That: do not use this method to unlock
     * otherwise not be catch for now
     */

    public entry fun transfer(set: Set, recipient: address, _: &mut TxContext) {
        transfer::public_transfer(set, recipient);
    }
}
