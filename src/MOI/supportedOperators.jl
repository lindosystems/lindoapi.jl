#=

 File: supportedOperators.jl
 Brief: Used to convert symbol type to EP codes for the instruction list

 Bugs:

 TODO: There are more EP_XXX that could be added

=#

Sym_To_EP = Dict(
    :+ => EP_PLUS,
    :- => EP_MINUS,
    :* => EP_MULTIPLY,
    :/ => EP_DIVIDE,
    :^ => EP_POWER,
    :(==) => EP_EQUAL,
    :(!=) => EP_NOT_EQUAL,
    :(<=) => EP_LTOREQ,
    :(>=) => EP_GTOREQ,
    :(<) => EP_LTHAN,
    :(>) => EP_GTHAN,
    :& => EP_AND,
    :| => EP_OR,
    :abs => EP_ABS,
    :sqrt => EP_SQRT,
    :log10 => EP_LOG,
    :log => EP_LN,
    :pi => EP_PI,
    :sin => EP_SIN,
    :cos => EP_COS,
    :tan => EP_TAN,
    :atan => EP_ATAN,
    :asin => EP_ASIN,
    :acos => EP_ACOS,
    :exp => EP_EXP,
    :mod => EP_MOD,
)
