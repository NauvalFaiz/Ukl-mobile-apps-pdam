import os
import re

lib_dir = r"c:\ukl-mobile-apps\lib"
file_locations = {
    # blocs
    "auth_bloc.dart": "package:uklmobileapps/features/auth/presentation/bloc/auth_bloc.dart",
    "auth_event.dart": "package:uklmobileapps/features/auth/presentation/bloc/auth_event.dart",
    "auth_state.dart": "package:uklmobileapps/features/auth/presentation/bloc/auth_state.dart",
    "bill_bloc.dart": "package:uklmobileapps/features/bill/presentation/bloc/bill_bloc.dart",
    "bill_event.dart": "package:uklmobileapps/features/bill/presentation/bloc/bill_event.dart",
    "bill_state.dart": "package:uklmobileapps/features/bill/presentation/bloc/bill_state.dart",
    "payment_bloc.dart": "package:uklmobileapps/features/payment/presentation/bloc/payment_bloc.dart",
    "payment_event.dart": "package:uklmobileapps/features/payment/presentation/bloc/payment_event.dart",
    "payment_state.dart": "package:uklmobileapps/features/payment/presentation/bloc/payment_state.dart",
    "onboarding_cubit.dart": "package:uklmobileapps/features/onboarding/presentation/bloc/onboarding_cubit.dart",
    
    # models
    "auth_response_model.dart": "package:uklmobileapps/features/auth/data/models/auth_response_model.dart",
    "user_model.dart": "package:uklmobileapps/features/auth/data/models/user_model.dart",
    "admin_model.dart": "package:uklmobileapps/features/admin/data/models/admin_model.dart",
    "bill_model.dart": "package:uklmobileapps/features/bill/data/models/bill_model.dart",
    "customer_model.dart": "package:uklmobileapps/features/customer/data/models/customer_model.dart",
    "payment_model.dart": "package:uklmobileapps/features/payment/data/models/payment_model.dart",
    "service_model.dart": "package:uklmobileapps/features/service/data/models/service_model.dart",
    
    # views
    "login_page.dart": "package:uklmobileapps/features/auth/presentation/views/login_page.dart",
    "splash_screen.dart": "package:uklmobileapps/features/onboarding/presentation/views/splash_screen.dart",
    "admin_dashboard.dart": "package:uklmobileapps/features/admin/presentation/views/admin_dashboard.dart",
    "customer_dashboard.dart": "package:uklmobileapps/features/customer/presentation/views/customer_dashboard.dart",
    
    # services
    "auth_service.dart": "package:uklmobileapps/features/auth/data/datasources/auth_service.dart",
    "api_client.dart": "package:uklmobileapps/core/network/api_client.dart",
    "dio_client.dart": "package:uklmobileapps/core/network/dio_client.dart",
    
    # shared
    "token_storage.dart": "package:uklmobileapps/core/storage/token_storage.dart",
}

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if not file.endswith('.dart'):
            continue
        filepath = os.path.join(root, file)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = content
        
        for match in re.finditer(r"import\s+['\"]([^'\"]+)['\"];", content):
            import_str = match.group(0)
            import_path = match.group(1)
            
            filename = import_path.split('/')[-1]
            if filename in file_locations:
                new_import = f"import '{file_locations[filename]}';"
                new_content = new_content.replace(import_str, new_import)
                
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {filepath}")
