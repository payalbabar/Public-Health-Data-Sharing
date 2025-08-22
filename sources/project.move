module MyModule::PublicHealthDataSharing {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::vector;

    /// Struct representing a health data record
    struct HealthDataRecord has store, key {
        data_entries: vector<String>,  // Anonymized health data entries
        total_records: u64,            // Total number of data records
        organization_name: String,     // Name of the health organization
        is_verified: bool,            // Verification status of the organization
    }

    /// Error codes
    const E_ORGANIZATION_NOT_FOUND: u64 = 1;
    const E_ORGANIZATION_NOT_VERIFIED: u64 = 2;

    /// Function to register a new health organization
    public fun register_organization(
        organization: &signer, 
        org_name: String
    ) {
        let health_record = HealthDataRecord {
            data_entries: vector::empty<String>(),
            total_records: 0,
            organization_name: org_name,
            is_verified: true,  // Auto-verify for simplicity
        };
        move_to(organization, health_record);
    }

    /// Function to add anonymized health data to the shared pool
    public fun add_health_data(
        organization: &signer,
        data_entry: String
    ) acquires HealthDataRecord {
        let org_address = signer::address_of(organization);
        
        // Check if organization exists
        assert!(exists<HealthDataRecord>(org_address), E_ORGANIZATION_NOT_FOUND);
        
        let health_record = borrow_global_mut<HealthDataRecord>(org_address);
        
        // Check if organization is verified
        assert!(health_record.is_verified, E_ORGANIZATION_NOT_VERIFIED);
        
        // Add the new data entry
        vector::push_back(&mut health_record.data_entries, data_entry);
        
        // Update total records count
        health_record.total_records = health_record.total_records + 1;
    }

    /// View function to get total records count (bonus helper function)
    #[view]
    public fun get_total_records(org_address: address): u64 acquires HealthDataRecord {
        let health_record = borrow_global<HealthDataRecord>(org_address);
        health_record.total_records
    }
}