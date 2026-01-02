#!/bin/bash
FILES=$(grep -rl "import '..[./]*cubit/auth_cubit.dart'" lib/features/authentication/)
for file in $FILES; do
  echo "Fixing $file"
  sed -i .bak "s|import '..[./]*cubit/auth_cubit.dart';|import 'package:am_common_ui/features/authentication/presentation/cubit/auth_cubit.dart';|g" "$file"
  sed -i .bak "s|import '..[./]*cubit/auth_state.dart';|import 'package:am_common_ui/features/authentication/presentation/cubit/auth_state.dart';|g" "$file"
  rm "${file}.bak"
done
