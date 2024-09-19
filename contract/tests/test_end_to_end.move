#[test_only]
module todolist_addr::test_end_to_end {
    use std::string;
    use aptos_framework::account;
    use aptos_std::debug;
    use std::signer;
    use aptos_std::string_utils;
    use todolist_addr::todolist;

    #[test(admin = @todolist_addr)]
    public entry fun test_end_to_end(admin: signer) {
        let admin_addr = signer::address_of(&admin);
        let todo_list_idx = todolist::get_todo_list_counter(admin_addr);
        assert!(todo_list_idx == 0, 1);
        account::create_account_for_test(admin_addr);
        assert!(!todolist::has_todo_list(admin_addr, todo_list_idx), 2);
        todolist::create_todo_list(&admin);
        assert!(todolist::get_todo_list_counter(admin_addr) == 1, 3);
        assert!(todolist::has_todo_list(admin_addr, todo_list_idx), 4);

        todolist::create_todo(&admin, todo_list_idx, string::utf8(b"New Todo"));
        let (todo_list_owner, todo_list_length) = todolist::get_todo_list(admin_addr, todo_list_idx);
        debug::print(&string_utils::format1(&b"todo_list_owner: {}", todo_list_owner));
        debug::print(&string_utils::format1(&b"todo_list_length: {}", todo_list_length));
        assert!(todo_list_owner == admin_addr, 5);
        assert!(todo_list_length == 1, 6);

        let (todo_content, todo_completed) = todolist::get_todo(admin_addr, todo_list_idx, 0);
        debug::print(&string_utils::format1(&b"todo_content: {}", todo_content));
        debug::print(&string_utils::format1(&b"todo_completed: {}", todo_completed));
        assert!(!todo_completed, 7);
        assert!(todo_content == string::utf8(b"New Todo"), 8);

        todolist::complete_todo(&admin, todo_list_idx, 0);
        let (_todo_content, todo_completed) = todolist::get_todo(admin_addr, todo_list_idx, 0);
        debug::print(&string_utils::format1(&b"todo_completed: {}", todo_completed));
        assert!(todo_completed, 9);
    }

    #[test(admin = @todolist_addr)]
    public entry fun test_end_to_end_2_todo_lists(admin: signer) {
        let admin_addr = signer::address_of(&admin);
        todolist::create_todo_list(&admin);
        let todo_list_1_idx = todolist::get_todo_list_counter(admin_addr) - 1;
        todolist::create_todo_list(&admin);
        let todo_list_2_idx = todolist::get_todo_list_counter(admin_addr) - 1;

        todolist::create_todo(&admin, todo_list_1_idx, string::utf8(b"New Todo"));
        let (todo_list_owner, todo_list_length) = todolist::get_todo_list(admin_addr, todo_list_1_idx);
        assert!(todo_list_owner == admin_addr, 1);
        assert!(todo_list_length == 1, 2);

        let (todo_content, todo_completed) = todolist::get_todo(admin_addr, todo_list_1_idx, 0);
        assert!(!todo_completed, 3);
        assert!(todo_content == string::utf8(b"New Todo"), 4);

        todolist::complete_todo(&admin, todo_list_1_idx, 0);
        let (_todo_content, todo_completed) = todolist::get_todo(admin_addr, todo_list_1_idx, 0);
        assert!(todo_completed, 5);

        todolist::create_todo(&admin, todo_list_2_idx, string::utf8(b"New Todo"));
        let (todo_list_owner, todo_list_length) = todolist::get_todo_list(admin_addr, todo_list_2_idx);
        assert!(todo_list_owner == admin_addr, 6);
        assert!(todo_list_length == 1, 7);

        let (todo_content, todo_completed) = todolist::get_todo(admin_addr, todo_list_2_idx, 0);
        assert!(!todo_completed, 8);
        assert!(todo_content == string::utf8(b"New Todo"), 9);

        todolist::complete_todo(&admin, todo_list_2_idx, 0);
        let (_todo_content, todo_completed) = todolist::get_todo(admin_addr, todo_list_2_idx, 0);
        assert!(todo_completed, 10);
    }

    #[test(admin = @todolist_addr)]
    #[expected_failure(abort_code = todolist::E_TODO_LIST_DOSE_NOT_EXIST)]
    public entry fun test_todo_list_does_not_exist(admin: signer) {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let todo_list_idx = todolist::get_todo_list_counter(admin_addr);
        todolist::create_todo(&admin, todo_list_idx, string::utf8(b"New Todo"));
    }

    #[test(admin = @todolist_addr)]
    #[expected_failure(abort_code = todolist::E_TODO_DOSE_NOT_EXIST)]
    public entry fun test_todo_does_not_exist(admin: signer) {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let todo_list_idx = todolist::get_todo_list_counter(admin_addr);
        todolist::create_todo_list(&admin);
        todolist::complete_todo(&admin, todo_list_idx, 1);
    }

    #[test(admin = @todolist_addr)]
    #[expected_failure(abort_code = todolist::E_TODO_ALREADY_COMPLETED)]
    public entry fun test_todo_already_completed(admin: signer) {
        let admin_addr = signer::address_of(&admin);
        account::create_account_for_test(admin_addr);
        let todo_list_idx = todolist::get_todo_list_counter(admin_addr);
        todolist::create_todo_list(&admin);
        todolist::create_todo(&admin, todo_list_idx, string::utf8(b"New Todo"));
        todolist::complete_todo(&admin, todo_list_idx, 0);
        todolist::complete_todo(&admin, todo_list_idx, 0);
    }
    
}
