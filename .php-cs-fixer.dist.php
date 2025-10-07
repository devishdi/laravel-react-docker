<?php

$finder = PhpCsFixer\Finder::create()
  ->in('web/modules/custom')
;

$config = new PhpCsFixer\Config();
return $config
  ->setRiskyAllowed(true)
  ->setRules([
    '@Symfony' => true,
    '@Symfony:risky' => true,
    'array_syntax' => ['syntax' => 'short'],
    'blank_line_after_opening_tag' => true,
    'declare_strict_types' => true,
    'linebreak_after_opening_tag' => true,
    'mb_str_functions' => true,
    'no_php4_constructor' => true,
    'no_superfluous_phpdoc_tags' => true,
    'no_unreachable_default_argument_value' => true,
    'no_useless_else' => true,
    'no_useless_return' => true,
    'ordered_imports' => true,
    'php_unit_strict' => true,
    'phpdoc_order' => true,
    'semicolon_after_instruction' => true,
    'strict_comparison' => true,
    'strict_param' => true,
    'single_quote' => true,
    'simplified_if_return' => true,
    'array_indentation' => true,
    'statement_indentation' => true,
    'method_chaining_indentation' => true,
    'heredoc_indentation' => true,
    'doctrine_annotation_indentation' => true,
    'phpdoc_indent' => true,
    'switch_continue_to_break' => true,
    'single_line_empty_body' => true,
  ])
  ->setFinder($finder)
  ->setCacheFile('web/assets/.php_cs.cache')
  ;

