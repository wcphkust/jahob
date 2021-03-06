public /*: claimedby PriorityQueue */ class PriorityQueueElement {
    public Object ob;
    public int key;
}

public class PriorityQueue
{
    private static PriorityQueueElement[] queue;
    private static int length;

    /*:
      public static specvar init :: bool = "False";
      public static specvar content :: "(obj * int) set";
      public static specvar smaxlen :: int;
      public static specvar slength :: int;

      static specvar spqueue :: "obj set";

      vardefs "init == (queue \<noteq> null)";
      vardefs "spqueue == {p. \<exists> i. 0 \<le> i \<and> i < length \<and> p = queue.[i]}";		   
      vardefs "content == {(x, y). EX p. p : spqueue & p..ob = x & p..key = y}";
      vardefs "smaxlen == queue..Array.length";
      vardefs "slength == length";
      
      invariant LengthLowerInv: "init \<longrightarrow> 0 \<le> length";
      invariant LengthUpperInv: "init \<longrightarrow> length \<le> queue..Array.length";
      invariant NonNullInv: "init \<longrightarrow> (\<forall> i. 0 \<le> i \<and> i < length \<longrightarrow> queue.[i] \<noteq> null)";
      invariant NullInv: 
       "init \<longrightarrow> (\<forall> i. length \<le> i \<and> i < queue..Array.length \<longrightarrow> queue.[i] = null)";
      invariant DistinctInv: "init \<longrightarrow> (\<forall> i j. 
        (0 \<le> i \<and> i < length \<and> 0 \<le> j \<and> j < length \<and> queue.[i] = queue.[j]) \<longrightarrow> i = j)"
      invariant OrderedInv: "init \<longrightarrow> (\<forall> i j.
       (0 \<le> i \<and> i < length \<and> 0 \<le> j \<and> j < length \<and> (j=i+i+1 \<or> j=i+i+2)
         \<longrightarrow> queue.[i]..key \<ge> queue.[j]..key))";
      invariant HiddenInv: "init \<longrightarrow> queue : hidden";

      invariant ContentInj: 
      "ALL e1 e2. e1 : spqueue & e2 : spqueue & e1 ~= e2 --> (e1..ob ~= e2..ob | e1..key ~= e2..key)";

    */

    public static void init(int len)
    /*: requires "\<not>init \<and> 0 \<le> len"
        modifies init, content, smaxlen, slength
	ensures "init \<and> content = {} \<and> smaxlen = len \<and> 
	         slength = 0"
    */
    {
	queue = new /*: hidden */ PriorityQueueElement[len];
	
	int i = 0;

	while /*: inv "(\<forall> j. 0 \<le> j \<and> j < i \<longrightarrow> 
		       queue.[i] = null) \<and>
                       (\<forall> a i. a ~= queue \<longrightarrow> 
		       a.[i] = old (a.[i]))" */
	    (i < queue.length) {
	    queue[i] = null;
	}
	length = 0;
    }

    public static int currLength()
    /*: requires "init"
        ensures "result = slength"
    */
    {
	return length;
    }
    
    public static int maxLength()
    /*: requires "init"
        ensures "result = smaxlen"
    */
    {
	return queue.length;
    }
    
    public static boolean isEmpty()
    /*: requires "init"
        ensures "result = (slength = 0)"
    */
    {
	return (length == 0);
    }

    public static boolean isFull()
    /*: requires "init"
        ensures "result = (slength = smaxlen)"
    */
    {
	return (length == queue.length);
    }
   
    private static int parent(int i)
    /*: requires "i > 0"
        ensures "result >= 0 & result < i & 
	         (i = result + result + 1 | i = result + result +2) &
		 alloc = old alloc"
     */
    {
	return (i-1)/2;
    }

    private static int left(int i)
    /*: requires "0 \<le> i"
        ensures "0 \<le> result \<and> i < result \<and> 
	         result = 2 * i + 1 \<and> alloc = old alloc"
     */
    {
	return (2*i + 1);
    }

    private static int right(int i)
    /*: requires "0 \<le> i"
        ensures "0 \<le> result \<and> i < result \<and> 
	         result = 2 * i + 2 \<and> alloc = old alloc"
     */
    {
	return (2*i + 2);
    }

    public static void insert(Object o1, int k1)
    /*: requires "init & o1 ~= null & slength < smaxlen & (o1, k1) ~: content"
        modifies content, slength
	ensures "content = old content Un {(o1, k1)} &
                 (slength = (old slength) + 1)"
    */
    {
	int i = length;
	length = length + 1;
	
	PriorityQueueElement e = new PriorityQueueElement();
	e.ob = o1;
	e.key = k1;

	while /*: inv "(comment ''IBounds'' (0 \<le> i \<and> i < length)) & 
		       e ~: spqueue &
		       alloc = old alloc Un {e} &
		       (comment ''RelToI''
		        (((i + i + 1 < length) -->
			  (queue.[(i + i + 1)]..PriorityQueueElement.key <
			   e..PriorityQueueElement.key)) &
			 ((i + i + 2 < length) -->
			  (queue.[(i + i + 2)]..PriorityQueueElement.key <
			   e..PriorityQueueElement.key)))) &
		       (comment ''ContentPostLoop''
		       (old spqueue = { p. EX j. 0 <= j & j < length &
                                          j ~= i & p = queue.[j] })) &
		       (ALL j. 0 <= j & j < length & j ~= i --> 
		               queue.[j] ~= null) & 
		       (comment ''PDBefore''
		        (ALL j k. 0 <= j & j < length & 0 <= k & k < length &
		                 queue.[j] = queue.[k] & j ~= i & k ~= i --> 
				 j = k)) &
		       theinv NullInv &
		       (comment ''OrderedSkipLoop''
		       (i = (old length) -->
		        (ALL j k. 
			 (0 <= j & j < (old length) & 0 <= k & 
			  k < (old length) &
			  ((k = j + j + 1) | (k = j + j + 2)) -->
			   queue.[j]..PriorityQueueElement.key >=
			   queue.[k]..PriorityQueueElement.key)))) &
		       (comment ''OrderedPostLoop''
		       (i ~= (old length) -->
		        (ALL j k. 
		         (0 <= j & j < length & 0 <= k & k < length &
			  ((k = j + j + 1) | (k = j + j + 2)) -->
			   queue.[j]..PriorityQueueElement.key >=
			   queue.[k]..PriorityQueueElement.key)))) \<and>
                       (\<forall> a i. a ~= queue \<longrightarrow> a.[i] = old (a.[i]))"
	      */
	    (i > 0 && queue[parent(i)].key < e.key)
	{
	    int p = parent(i);

	    //: noteThat PBounds: "0 \<le> p \<and> p < old length";
	    // noteThat PIRel: "i = p + p + 1 | i = p + p + 2";
	    // note InLoop: "queue.[p]..key < e..key";

	    queue[i] = queue[p];

	    /* note iEffect1: "ALL jj. (0 \<le> jj \<and> jj < length \<and> 
	        ((i = jj + jj + 1) | (i = jj + jj + 2)) \<longrightarrow> 
	        queue.[jj]..key \<ge> queue.[i]..key)"; */

	    /* note iEffect2: "ALL kk. (0 \<le> kk \<and> kk < length \<and>
	        ((kk = i + i + 1) | (kk = i + i + 2)) \<longrightarrow>
	        queue.[i]..key \<ge> queue.[kk]..key)" 
	        from OrderedPostLoop, InLoop, PIRel, PBounds; */

	    /* note OtherEffect: 
	      "ALL jj kk. (0 \<le> jj \<and> jj < length \<and> 0 \<le> kk \<and> kk < length \<and> 
	       jj \<noteq> i \<and> kk \<noteq> i \<and> ((kk = jj + jj + 1) | (kk = jj + jj + 2)) \<longrightarrow> 
	       queue.[jj]..key \<ge> queue.[kk]..key)"; */

	    i = p;

	    /* noteThat sameAfter:
	      "ALL jj kk. (0 <= jj & jj < length & 0 <= kk & kk < length & 
	      ((kk = jj + jj + 1) | (kk = jj + jj + 2)) -->
	      queue.[jj]..PriorityQueueElement.key >=
	      queue.[kk]..PriorityQueueElement.key)" 
	      from iEffect1, iEffect2, OtherEffect; */

	    /*: noteThat ContentAfter:
	      "old spqueue = 
	       { p. EX j. 0 <= j & j < length & j ~= i & p = queue.[j] }"
	      from ContentPostLoop, IBounds, PBounds;
	    */
	    /* noteThat PDAfter:
	      "(ALL j k. 0 <= j & j < length & 0 <= k & k < length &
	                 queue.[j] = queue.[k] & j ~= i & k ~= i --> j = k)"
	      from PDBefore, PBounds;
	    */
	}
	queue[i] = e;

	/*: noteThat ContentDef:
	  "spqueue = {p. (EX i. 0 <= i & i < length & p = queue.[i])}"; */

	/*: noteThat NewSpqueue: "spqueue = old spqueue Un { e }"
	  from ContentPostLoop, ContentDef, IBounds; */

	//: note ContentForw: "ALL x y. (x, y) : content --> (x, y) : old content Un {(o1, k1)}" from content_def, NewSpqueue;
	{
	    //: pickAny x::obj, y::int;
	    {
		//: assuming Hyp: "(x, y) : old content Un {(o1, k1)}";
		{
		    //: assuming Hyp1: "(x, y) : old content";
		    //: note ENotInOld: "e ~: old spqueue";
		    //: note Conc1: "(x, y) : content" from content_def, ContentDef, NewSpqueue, Hyp1, ENotInOld;
		}
		//: note NewElemInContent: "(o1, k1) : content";
		//: note Conc: "(x, y) : content" from NewElemInContent, Conc1, Hyp;
	    }
	    //: note ContentBack: "(x, y) : old content Un {(o1, k1)} --> (x, y) : content" forSuch x, y;
	}
	//: note ContentPost: "content = old content Un {(o1, k1)}" from ContentForw, ContentBack;

	{
	    //: pickAny e1::obj, e2::obj;
	    {
		//: assuming Hyp: "e1 : spqueue & e2 : spqueue & e1 ~= e2"
		{
		    //: assuming OldEs: "e1 : old spqueue & e2 : old spqueue";
		    //: note Conc1: "e1..ob ~= e2..ob | e1..key ~= e2..key";
		}
		{
		    //: assuming NewE1: "e1 ~: old spqueue";
		    //: note NewEntry: "(o1, k1) ~: old content";
		    //: note Conc2: "e1..ob ~= e2..ob | e1..key ~= e2..key" from Hyp, NewE1, content_def, NewSpqueue, NewEntry;
		}
		{
		    //: assuming NewE2: "e2 ~: old spqueue";
		    //: note NewEntry: "(o1, k1) ~: old content";
		    //: note Conc3: "e1..ob ~= e2..ob | e1..key ~= e2..key" from Hyp, NewE2, content_def, NewSpqueue, NewEntry;
		}
		//: note Conc: "e1..ob ~= e2..ob | e1..key ~= e2..key" from Conc1, Conc2, Conc3;
	    }
	    //: note ContentInj: "e1 : spqueue & e2 : spqueue & e1 ~= e2 --> (e1..ob ~= e2..ob | e1..key ~= e2..key)" forSuch e1, e2;
	}
    }

    public static Object findMax()
    /*: requires "init \<and> slength > 0"
        ensures "(EX pr. (result, pr) \<in> content \<and>
	         (\<forall> x y. (x, y) \<in> content \<longrightarrow> 
		 pr \<ge> y))" */
    {
	{
	    //: assuming OrderingHyp1: "ALL i j. 0 <= i & i < length & 0 <= j & j < length & (j = i + i + 1 | j = i + i + 2) --> queue.[i]..key >= queue.[j]..key";
	    {
		//: pickAny k::int;
		{
		    //: assuming OrderingHyp2: "0 <= k & k < length";
		    //: note ArrLength: "0 < length";
		    {
			//: induct InGeneral: "ALL x. x <= kk & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key" over kk::int;
			//: note BaseCase: "ALL x. x <= 0 & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key";
			{
			    //: assuming InductHyp1: "ALL x. x <= kk & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key";
			    {
				//: pickAny x::int;
				{
				    //: assuming InductHyp2: "x <= (kk + 1) & 0 <= x & x < length";
				    {
					//: assuming LtHyp: "x < kk + 1";
					//: note LtConc: "queue.[0]..key >= queue.[x]..key";
				    }
				    {
					//: assuming EqHyp: "x = kk + 1";
					{
					    //: assuming EvenHyp: "x mod 2 = 0";
					    //: note EvenParent: "EX y. y + y = x" from EvenHyp;
					    //: pickWitness evenp::int suchThat ParentRel: "evenp + evenp = x";
					    //: note ParentGE: "queue.[evenp - 1]..key >= queue.[x]..key" from OrderingHyp1, EqHyp, ParentRel, OrderingHyp2, InGeneral, InductHyp2;
					    //: note ParentInduct: "queue.[0]..key >= queue.[evenp - 1]..key" from InductHyp1, InductHyp2, EqHyp, ParentRel, InGeneral;
					    //: note EvenConc: "queue.[0]..key >= queue.[x]..key" from ParentInduct, ParentGE;
					}
					{
					    //: assuming OddHyp: "x mod 2 = 1";
					    //: note OddParent: "EX y. y + y + 1 = x" from OddHyp;
					    //: pickWitness oddp::int suchThat ParentRel: "oddp + oddp + 1 = x";
					    //: note ParentGE: "queue.[oddp]..key >= queue.[x]..key" from OrderingHyp1, ParentRel, InductHyp2;
					    //: note ParentInduct: "queue.[0]..key >= queue.[oddp]..key" from InductHyp1, InductHyp2, EqHyp, ParentRel;
					    //: note OddConc: "queue.[0]..key >= queue.[x]..key" from ParentInduct, ParentGE;
					}
					//: note EqConc: "queue.[0]..key >= queue.[x]..key" from EvenConc, OddConc;
					
				    }
				    //: note InductConc3: "queue.[0]..key >= queue.[x]..key" from LtConc, EqConc, InductHyp2;
				}
				//: note InductConc2: "x <= (kk + 1) & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key" forSuch x;
			    }
			    //: note InductConc1: "ALL x. x <= (kk + 1) & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key";
			}
		    }
		    //: note OrderingConc2: "queue.[0]..key >= queue.[k]..key" from InGeneral, ArrLength, OrderingHyp2;
		}
		//: note OrderingAll: "0 <= k & k < length --> queue.[0]..key >= queue.[k]..key" forSuch k;
	    }
	    //: note OrderingConc1: "ALL k. 0 <= k & k < length --> queue.[0]..key >= queue.[k]..key";
	}
	//: note QueueDef: "spqueue = {p. EX i. 0 <= i & i < length & p = queue.[i]}";
	//: note LengthLemma: "0 < length";
	//: note FoundElem: "queue.[0] : spqueue" from QueueDef, LengthLemma;
	//: note IsMax: "ALL x y. (x, y) : content --> queue.[0]..key >= y";
	return queue[0].ob;
    }

    public static Object extractMax()
    /*: requires "init \<and> slength > 0"
        modifies content, slength
        ensures  "slength = old slength - 1 \<and> 
	          (EX pr. content = old content - { (result, pr) } \<and>
		  (\<forall> x y. (x, y) \<in> (old content) \<longrightarrow> pr \<ge> y))" */
    {
	PriorityQueueElement result = queue[0];
	{
	    //: assuming OrderingHyp1: "ALL i j. 0 <= i & i < length & 0 <= j & j < length & (j = i + i + 1 | j = i + i + 2) --> queue.[i]..key >= queue.[j]..key";
	    {
		//: pickAny k::int;
		{
		    //: assuming OrderingHyp2: "0 <= k & k < length";
		    //: note ArrLength: "0 < length";
		    {
			//: induct InGeneral: "ALL x. x <= kk & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key" over kk::int;
			//: note BaseCase: "ALL x. x <= 0 & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key";
			{
			    //: assuming InductHyp1: "ALL x. x <= kk & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key";
			    {
				//: pickAny x::int;
				{
				    //: assuming InductHyp2: "x <= (kk + 1) & 0 <= x & x < length";
				    {
					//: assuming LtHyp: "x < kk + 1";
					//: note LtConc: "queue.[0]..key >= queue.[x]..key";
				    }
				    {
					//: assuming EqHyp: "x = kk + 1";
					{
					    //: assuming EvenHyp: "x mod 2 = 0";
					    //: note EvenParent: "EX y. y + y = x" from EvenHyp;
					    //: pickWitness evenp::int suchThat ParentRel: "evenp + evenp = x";
					    //: note ParentGE: "queue.[evenp - 1]..key >= queue.[x]..key" from OrderingHyp1, EqHyp, ParentRel, OrderingHyp2, InGeneral, InductHyp2;
					    //: note ParentInduct: "queue.[0]..key >= queue.[evenp - 1]..key" from InductHyp1, InductHyp2, EqHyp, ParentRel, InGeneral;
					    //: note EvenConc: "queue.[0]..key >= queue.[x]..key" from ParentInduct, ParentGE;
					}
					{
					    //: assuming OddHyp: "x mod 2 = 1";
					    //: note OddParent: "EX y. y + y + 1 = x" from OddHyp;
					    //: pickWitness oddp::int suchThat ParentRel: "oddp + oddp + 1 = x";
					    //: note ParentGE: "queue.[oddp]..key >= queue.[x]..key" from OrderingHyp1, ParentRel, InductHyp2;
					    //: note ParentInduct: "queue.[0]..key >= queue.[oddp]..key" from InductHyp1, InductHyp2, EqHyp, ParentRel;
					    //: note OddConc: "queue.[0]..key >= queue.[x]..key" from ParentInduct, ParentGE;
					}
					//: note EqConc: "queue.[0]..key >= queue.[x]..key" from EvenConc, OddConc;
					
				    }
				    //: note InductConc3: "queue.[0]..key >= queue.[x]..key" from LtConc, EqConc, InductHyp2;
				}
				//: note InductConc2: "x <= (kk + 1) & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key" forSuch x;
			    }
			    //: note InductConc1: "ALL x. x <= (kk + 1) & 0 <= x & x < length --> queue.[0]..key >= queue.[x]..key";
			}
		    }
		    //: note OrderingConc2: "queue.[0]..key >= queue.[k]..key" from InGeneral, ArrLength, OrderingHyp2;
		}
		//: note OrderingAll: "0 <= k & k < length --> queue.[0]..key >= queue.[k]..key" forSuch k;
	    }
	    //: note OrderingConc1: "ALL k. 0 <= k & k < length --> queue.[0]..key >= queue.[k]..key";
	}
	length = length - 1;
	queue[0] = queue[length];
	queue[length] = null;
	//: noteThat IntQueueContent: "spqueue = old spqueue - { result }";
	if (0 < length) heapify(0);
	/*: noteThat FinalQueueContent: "spqueue = old spqueue - { result }"
	  from IntQueueContent, heapify_Postcond, FinalQueueContent; */

	{
	    //: pickAny x1::obj, y1::int;
	    {
		//: assuming RemovedForwHyp: "(x1, y1) : content";
		//: note ResultInOld: "result : old spqueue";
		//: note ContentInjLemma: "ALL e1 e2. e1 : old spqueue & e2 : old spqueue & e1 ~= e2 --> (e1..ob ~= e2..ob | e1..key ~= e2..key)";
		//: note RemovedForwConc: "(x1, y1) : old content - {(result..ob, result..key)}" from Hyp, ContentInjLemma, content_def, FinalQueueContent, ResultInOld;
	    }
	    //: note RemovedForw: "(x1, y1) : content --> (x1, y1) : old content - {(result..ob, result..key)}" forSuch x1, y1;
	}
	{
	    //: pickAny x2::obj, y2::int;
	    {
		//: assuming RemovedBackHyp: "(x2, y2) : old content - {(result..ob, result..key)}";
		//: note RemovedBackConc: "(x2, y2) : content" from content_def, RemovedBackHyp, FinalQueueContent;
	    }
	    //: note RemovedBack: "(x2, y2) : old content - {(result..ob, result..key)} --> (x2, y2) : content" forSuch x2, y2;
	}
	//: note RemovedPair: "content = old content - {(result..ob, result..key)}" from RemovedForw, RemovedBack;
	//: note IsMax: "ALL x y. (x, y) : old content --> result..key >= y";
	/*: witness "result..key" for
	  PostCond: "EX pr. content = old content - {(result..ob, pr)} & (ALL x y. (x, y) : (old content) --> pr >= y)"
	  from RemovedPair, IsMax; */

	return result.ob;
    }

    private static void heapify(int i)
    /*: requires "init \<and> 0 \<le> i \<and> i < length \<and> theinv LengthLowerInv \<and>
                  theinv LengthUpperInv \<and> theinv NonNullInv \<and>
		  theinv NullInv \<and> theinv DistinctInv \<and>
		  (comment ''GlobalOrderingPre''
		   (ALL k j.
		    (0 <= k & k < length & k ~= i & 0 < j & j < length &
		    ((j = k + k + 1) | (j = k + k + 2)) -->
		    queue.[k]..PriorityQueueElement.key >=
		    queue.[j]..PriorityQueueElement.key))) \<and> 
		  (comment ''LocalOrderingPre''
		   (ALL x. 
		    ((0 <= x & (i = x + x + 1 | i = x + x + 2)) -->
		     (((i + i + 1 < length) --> 
		      queue.[x]..PriorityQueueElement.key >=
		      queue.[(i + i + 1)]..PriorityQueueElement.key) &
		      ((i + i + 2 < length) -->
		      queue.[x]..PriorityQueueElement.key >=
		      queue.[(i + i + 2)]..PriorityQueueElement.key))))) \<and> 
	         theinv HiddenInv \<and>
		 theinv ContentInj"
        modifies "Array.arrayState"
        ensures "init = old init \<and> 
	         spqueue = old spqueue \<and>
		 smaxlen = old smaxlen \<and>
		 slength = old slength \<and>
	         alloc = old alloc \<and> theinvs \<and>
	         (\<forall> a i. a \<noteq> queue \<longrightarrow> 
		  a.[i] = old (a.[i]))" */
    {
	int m = i;

	int l = left(i);
	if (l < length && queue[l].key > queue[i].key)
	    m = l;

	int r = right(i);
	if (r < length && queue[r].key > queue[m].key)
	    m = r;

	if (m != i)
	{
	    PriorityQueueElement p = queue[m];
	    queue[m] = queue[i];
	    queue[i] = p;
	    heapify(m);
	}
    }
}
