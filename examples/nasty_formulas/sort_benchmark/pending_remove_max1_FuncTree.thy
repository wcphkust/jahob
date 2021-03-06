theory PendingVC = Jahob:

lemma FuncTree_remove_max1_14: "([|((fieldRead Pair_data null) = null);
((fieldRead FuncTree_data null) = null);
((fieldRead FuncTree_left null) = null);
((fieldRead FuncTree_right null) = null);
(ALL xObj. (xObj : Object));
((Pair Int FuncTree) = {null});
((Array Int FuncTree) = {null});
((Array Int Pair) = {null});
(null : Object_alloc);
(pointsto Pair Pair_data Object);
(pointsto FuncTree FuncTree_data Object);
(pointsto FuncTree FuncTree_left FuncTree);
(pointsto FuncTree FuncTree_right FuncTree);
comment ''unalloc_lonely'' (ALL x. ((x ~: Object_alloc) --> ((ALL y. ((fieldRead Pair_data y) ~= x)) & (ALL y. ((fieldRead FuncTree_data y) ~= x)) & (ALL y. ((fieldRead FuncTree_left y) ~= x)) & (ALL y. ((fieldRead FuncTree_right y) ~= x)) & ((fieldRead Pair_data x) = null) & ((fieldRead FuncTree_data x) = null) & ((fieldRead FuncTree_left x) = null) & ((fieldRead FuncTree_right x) = null))));
comment ''ProcedurePrecondition'' ((k, v) : (fieldRead FuncTree_content t));
comment ''ProcedurePrecondition'' (ALL x. ((x ~= k) --> (ALL y. (((x, y) : (fieldRead FuncTree_content t)) --> (intless x k)))));
comment ''contentDefinitionProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_content this) = (({((fieldRead FuncTree_key this), (fieldRead FuncTree_data this))} Un (fieldRead FuncTree_content (fieldRead FuncTree_left this))) Un (fieldRead FuncTree_content (fieldRead FuncTree_right this))))));
comment ''nullEmptyProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree) & (this = null)) --> ((fieldRead FuncTree_content this) = {})));
comment ''dataNotNullProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_data this) ~= null)));
comment ''leftSmallerProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree)) --> (ALL k. (ALL v. (((k, v) : (fieldRead FuncTree_content (fieldRead FuncTree_left this))) --> (intless k (fieldRead FuncTree_key this)))))));
comment ''rightBiggerProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree)) --> (ALL k. (ALL v. (((k, v) : (fieldRead FuncTree_content (fieldRead FuncTree_right this))) --> ((fieldRead FuncTree_key this) < k))))));
comment ''t_type'' (t : FuncTree);
comment ''t_type'' (t : Object_alloc);
comment ''v_type'' (v : Object);
comment ''v_type'' (v : Object_alloc);
comment ''FalseBranch'' ((fieldRead FuncTree_right t) ~= null);
comment ''FuncTree.remove_max1_Postcondition'' (tmp_5_297 ~= (fieldRead FuncTree_right t));
comment ''FuncTree.remove_max1_Postcondition'' ((fieldRead FuncTree_content tmp_5_297) = ((fieldRead FuncTree_content (fieldRead FuncTree_right t)) - {(k, v)}));
comment ''FuncTree.remove_max1_Postcondition'' (ALL x. (ALL y. (((x, y) : (fieldRead FuncTree_content tmp_5_297)) --> (intless x k))));
comment ''contentDefinitionFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_content this) = (({((fieldRead FuncTree_key this), (fieldRead FuncTree_data this))} Un (fieldRead FuncTree_content (fieldRead FuncTree_left this))) Un (fieldRead FuncTree_content (fieldRead FuncTree_right this))))));
comment ''nullEmptyFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree) & (this = null)) --> ((fieldRead FuncTree_content this) = {})));
comment ''dataNotNullFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_data this) ~= null)));
comment ''leftSmallerFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree)) --> (ALL k__65. (ALL v__66. (((k__65, v__66) : (fieldRead FuncTree_content (fieldRead FuncTree_left this))) --> (intless k__65 (fieldRead FuncTree_key this)))))));
comment ''rightBiggerFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree)) --> (ALL k__67. (ALL v__68. (((k__67, v__68) : (fieldRead FuncTree_content (fieldRead FuncTree_right this))) --> ((fieldRead FuncTree_key this) < k__67))))));
comment ''FuncTree.remove_max1_Postcondition'' (Object_alloc \<subseteq> Object_alloc_298);
comment ''tmp_5_type'' (tmp_5_297 : FuncTree);
comment ''tmp_5_type'' (tmp_5_297 : Object_alloc_298);
comment ''AllocatedObject'' (tmp_6_295 ~= null);
comment ''AllocatedObject'' (tmp_6_295 ~: Object_alloc_298);
comment ''AllocatedObject'' (tmp_6_295 : FuncTree);
comment ''AllocatedObject'' (ALL y. ((fieldRead Pair_data y) ~= tmp_6_295));
comment ''AllocatedObject'' (ALL y. ((fieldRead FuncTree_data y) ~= tmp_6_295));
comment ''AllocatedObject'' (ALL y. ((fieldRead FuncTree_left y) ~= tmp_6_295));
comment ''AllocatedObject'' (ALL y. ((fieldRead FuncTree_right y) ~= tmp_6_295));
comment ''AllocatedObject'' ((fieldRead Pair_data tmp_6_295) = null);
comment ''AllocatedObject'' ((fieldRead FuncTree_data tmp_6_295) = null);
comment ''AllocatedObject'' ((fieldRead FuncTree_left tmp_6_295) = null);
comment ''AllocatedObject'' ((fieldRead FuncTree_right tmp_6_295) = null);
((x_bv15085, y_bv15134) : (fieldRead (fieldWrite FuncTree_content tmp_6_295 ((fieldRead FuncTree_content t) - {(k, v)})) tmp_6_295))|] ==>
    comment ''ProcedureEndPostcondition'' (intless x_bv15085 k))"
sorry

lemma FuncTree_remove_max1_15: "([|((fieldRead Pair_data null) = null);
((fieldRead FuncTree_data null) = null);
((fieldRead FuncTree_left null) = null);
((fieldRead FuncTree_right null) = null);
(ALL xObj. (xObj : Object));
((Pair Int FuncTree) = {null});
((Array Int FuncTree) = {null});
((Array Int Pair) = {null});
(null : Object_alloc);
(pointsto Pair Pair_data Object);
(pointsto FuncTree FuncTree_data Object);
(pointsto FuncTree FuncTree_left FuncTree);
(pointsto FuncTree FuncTree_right FuncTree);
comment ''unalloc_lonely'' (ALL x. ((x ~: Object_alloc) --> ((ALL y. ((fieldRead Pair_data y) ~= x)) & (ALL y. ((fieldRead FuncTree_data y) ~= x)) & (ALL y. ((fieldRead FuncTree_left y) ~= x)) & (ALL y. ((fieldRead FuncTree_right y) ~= x)) & ((fieldRead Pair_data x) = null) & ((fieldRead FuncTree_data x) = null) & ((fieldRead FuncTree_left x) = null) & ((fieldRead FuncTree_right x) = null))));
comment ''ProcedurePrecondition'' ((k, v) : (fieldRead FuncTree_content t));
comment ''ProcedurePrecondition'' (ALL x. ((x ~= k) --> (ALL y. (((x, y) : (fieldRead FuncTree_content t)) --> (intless x k)))));
comment ''contentDefinitionProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_content this) = (({((fieldRead FuncTree_key this), (fieldRead FuncTree_data this))} Un (fieldRead FuncTree_content (fieldRead FuncTree_left this))) Un (fieldRead FuncTree_content (fieldRead FuncTree_right this))))));
comment ''nullEmptyProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree) & (this = null)) --> ((fieldRead FuncTree_content this) = {})));
comment ''dataNotNullProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_data this) ~= null)));
comment ''leftSmallerProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree)) --> (ALL k. (ALL v. (((k, v) : (fieldRead FuncTree_content (fieldRead FuncTree_left this))) --> (intless k (fieldRead FuncTree_key this)))))));
comment ''rightBiggerProcedurePrecondition'' (ALL this. (((this : Object_alloc) & (this : FuncTree)) --> (ALL k. (ALL v. (((k, v) : (fieldRead FuncTree_content (fieldRead FuncTree_right this))) --> ((fieldRead FuncTree_key this) < k))))));
comment ''t_type'' (t : FuncTree);
comment ''t_type'' (t : Object_alloc);
comment ''v_type'' (v : Object);
comment ''v_type'' (v : Object_alloc);
comment ''FalseBranch'' ((fieldRead FuncTree_right t) ~= null);
comment ''FuncTree.remove_max1_Postcondition'' (tmp_5_297 ~= (fieldRead FuncTree_right t));
comment ''FuncTree.remove_max1_Postcondition'' ((fieldRead FuncTree_content tmp_5_297) = ((fieldRead FuncTree_content (fieldRead FuncTree_right t)) - {(k, v)}));
comment ''FuncTree.remove_max1_Postcondition'' (ALL x. (ALL y. (((x, y) : (fieldRead FuncTree_content tmp_5_297)) --> (intless x k))));
comment ''contentDefinitionFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_content this) = (({((fieldRead FuncTree_key this), (fieldRead FuncTree_data this))} Un (fieldRead FuncTree_content (fieldRead FuncTree_left this))) Un (fieldRead FuncTree_content (fieldRead FuncTree_right this))))));
comment ''nullEmptyFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree) & (this = null)) --> ((fieldRead FuncTree_content this) = {})));
comment ''dataNotNullFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree) & (this ~= null)) --> ((fieldRead FuncTree_data this) ~= null)));
comment ''leftSmallerFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree)) --> (ALL k__65. (ALL v__66. (((k__65, v__66) : (fieldRead FuncTree_content (fieldRead FuncTree_left this))) --> (intless k__65 (fieldRead FuncTree_key this)))))));
comment ''rightBiggerFuncTree.remove_max1_Postcondition'' (ALL this. (((this : Object_alloc_298) & (this : FuncTree)) --> (ALL k__67. (ALL v__68. (((k__67, v__68) : (fieldRead FuncTree_content (fieldRead FuncTree_right this))) --> ((fieldRead FuncTree_key this) < k__67))))));
comment ''FuncTree.remove_max1_Postcondition'' (Object_alloc \<subseteq> Object_alloc_298);
comment ''tmp_5_type'' (tmp_5_297 : FuncTree);
comment ''tmp_5_type'' (tmp_5_297 : Object_alloc_298);
comment ''AllocatedObject'' (tmp_6_295 ~= null);
comment ''AllocatedObject'' (tmp_6_295 ~: Object_alloc_298);
comment ''AllocatedObject'' (tmp_6_295 : FuncTree);
comment ''AllocatedObject'' (ALL y. ((fieldRead Pair_data y) ~= tmp_6_295));
comment ''AllocatedObject'' (ALL y. ((fieldRead FuncTree_data y) ~= tmp_6_295));
comment ''AllocatedObject'' (ALL y. ((fieldRead FuncTree_left y) ~= tmp_6_295));
comment ''AllocatedObject'' (ALL y. ((fieldRead FuncTree_right y) ~= tmp_6_295));
comment ''AllocatedObject'' ((fieldRead Pair_data tmp_6_295) = null);
comment ''AllocatedObject'' ((fieldRead FuncTree_data tmp_6_295) = null);
comment ''AllocatedObject'' ((fieldRead FuncTree_left tmp_6_295) = null);
comment ''AllocatedObject'' ((fieldRead FuncTree_right tmp_6_295) = null);
(this_bv14988 : (Object_alloc_298 Un {tmp_6_295}));
(this_bv14988 : FuncTree);
(this_bv14988 ~= null)|] ==>
    comment ''contentDefinition_ProcedureEndPostcondition'' ((fieldRead (fieldWrite FuncTree_content tmp_6_295 ((fieldRead FuncTree_content t) - {(k, v)})) this_bv14988) = (({((fieldRead (fieldWrite FuncTree_key tmp_6_295 (fieldRead FuncTree_key t)) this_bv14988), (fieldRead (fieldWrite FuncTree_data tmp_6_295 (fieldRead FuncTree_data t)) this_bv14988))} Un (fieldRead (fieldWrite FuncTree_content tmp_6_295 ((fieldRead FuncTree_content t) - {(k, v)})) (fieldRead (fieldWrite FuncTree_left tmp_6_295 (fieldRead FuncTree_left t)) this_bv14988))) Un (fieldRead (fieldWrite FuncTree_content tmp_6_295 ((fieldRead FuncTree_content t) - {(k, v)})) (fieldRead (fieldWrite FuncTree_right tmp_6_295 tmp_5_297) this_bv14988)))))"
sorry


end
