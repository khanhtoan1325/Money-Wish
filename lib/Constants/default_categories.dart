import 'package:expanse_management/domain/models/category_model.dart';

final List<CategoryModel> defaultIncomeCategories = [
  CategoryModel(title: 'Salary', categoryImage: 'Salary.png', type: 'Income'),
  CategoryModel(title: 'Gifts', categoryImage: 'Gifts.png', type: 'Income'),
  CategoryModel(title: 'Investments', categoryImage: 'Investments.png', type: 'Income'),
  CategoryModel(title: 'Rentals', categoryImage: 'Rentals.png', type: 'Income'),
  CategoryModel(title: 'Savings', categoryImage: 'Savings.png', type: 'Income'),
  CategoryModel(title: 'Others Income', categoryImage: 'Others.png', type: 'Income'),
];

final List<CategoryModel> defaultExpenseCategories = [
  CategoryModel(title: 'Food', categoryImage: 'Food.png', type: 'Expense'),
  CategoryModel(title: 'Transportation', categoryImage: 'Transportation.png', type: 'Expense'),
  CategoryModel(title: 'Education', categoryImage: 'Education.png', type: 'Expense'),
  CategoryModel(title: 'Bills', categoryImage: 'Bills.png', type: 'Expense'),
  CategoryModel(title: 'Travels', categoryImage: 'Travels.png', type: 'Expense'),
  CategoryModel(title: 'Pets', categoryImage: 'Pets.png', type: 'Expense'),
  CategoryModel(title: 'Tax', categoryImage: 'Tax.png', type: 'Expense'),
  CategoryModel(title: 'Others Expense', categoryImage: 'Others.png', type: 'Expense'),
];
