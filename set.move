module toraii::set {
    use sui::url::{Self, Url};
    use std::string::{Self, utf8};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::clock::{Self, Clock};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::package;
    use sui::display;


    struct Set has key, store {
        id: UID,
        /// Name for the token
        name: string::String,
        /// Description of the token
        description: string::String,
        // Id
        reach_tx_hash : string::String,
        // uid of set
        uid : string::String,
        // definitionId of set
        data_id: string::String,
        /// URL for the token
        url: Url
    }

    struct SetManCap has key, store { 
        id: UID
    }

    // ===== Events =====

    struct SetMinted has copy, drop {
        // The Object ID of the set
        event_id: ID,
        uid: string::String,
        // The receiver of the set
        receiver: address,
        // The name of the set
        name: string::String,
        // The id of set in reach
        reach_tx_hash: string::String,
        // definitionId
        data_id: string::String
    }
    struct SetUnlocked has copy, drop {
        name: string::String,
        description: string::String, 
        reach_tx_hash: string::String, 
        uid: string::String, 
        data_id: string::String, 
        ts_ms: u64, 
        from: address 
    }


    // ===== Public view functions =====

    /// Get the SET's `name`
    public fun name(set: &Set): &string::String {
        &set.name
    }

    /// Get the SET's `description`
    public fun description(set: &Set): &string::String {
        &set.description
    }

    /// Get the SET's `url`
    public fun url(set: &Set): &Url {
        &set.url
    }

    struct SET has drop {}

    // ===== Init to get Cap =====
    fun init(otw: SET, ctx: &mut TxContext) {
        let cap = SetManCap{id:object::new(ctx)};

        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            // For `name` we can use the `Hero.name` property
            utf8(b"{name}"),
            // For `link` we can build a URL using an `id` property
            utf8(b"https://1278ab45.torai-money.pages.dev/logo.png"),
            // For `img_url` we use an IPFS template.
            utf8(b"https://1278ab45.torai-money.pages.dev/logo.png"),
            // Description is static for all `Hero` objects.
            utf8(b"A SET in REACH ecosystem!"),
            // Project URL is usually static
            utf8(b"https://torai.money"),
            // Creator field can be any
            utf8(b"TORAI!")
        ];

        // Claim the `Publisher` for the package!
        let publisher = package::claim(otw, ctx);

        // Get a new `Display` object for the `Hero` type.
        let display = display::new_with_fields<Set>(
            &publisher, keys, values, ctx
        );

        // Commit first version of `Display` to apply changes.
        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));

        transfer::public_transfer(cap, tx_context::sender(ctx));
    }


    // ===== Entrypoints =====

    /// Create a new set
    public entry fun mint_to_with_cap(
        _: &SetManCap,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        recipient: address,
        reach_tx_hash: string::String,
        uid: string::String,
        data_id: string::String,
        ctx: &mut TxContext
    ) {
        let set = Set {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            reach_tx_hash: reach_tx_hash,
            uid: uid,
            data_id: data_id,
            url: url::new_unsafe_from_bytes(url)
        };

        event::emit(SetMinted {
            event_id: object::id(&set),
            uid: set.uid,
            receiver: recipient,
            name: set.name,
            reach_tx_hash: reach_tx_hash,
            data_id: data_id
        });

        transfer::public_transfer(set, recipient);
    }

    public fun burn(
        set: Set,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        let ts_ms = clock::timestamp_ms(clock);
        let Set { id:id, name: name, description: description, reach_tx_hash: reach_tx_hash, uid: uid, data_id:data_id, url: _} = set;
        object::delete(id);
        event::emit(SetUnlocked {name, description, reach_tx_hash, uid, data_id, ts_ms, from:tx_context::sender(ctx)});
    }
    
}

