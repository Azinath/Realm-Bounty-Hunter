function RBH_HitListSort(self)
   table.sort(RBH_HitList,RBH_SortBy(self.sortType,a,b))
    RBH_HitListUpdate()
end

function RBH_SortBy(sortType,a,b)
   
end