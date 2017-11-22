#!/bin/bash

# 判断Vim的版本是不是basic，如果是，返回0；否则返回1
function checkVimVersion() {
	# 先获取vim可执行命令的位置
	vimLoc=$(which vim || which vi)

	# 如果该位置的文件是链接文件
	while [ -L $vimLoc ]; do
		# 通过ls -l命令以及sed命令取出该链接文件对应的文件
		vimLoc=$(ls -l $vimLoc | sed -r 's/.+-> ([^ ]+).*/\1/')
	done

	# 最终得到vim命令对应的可执行文件对应的位置，
	# 通过sed命令取出vim对应的版本，比如: tiny, basic等
	vimVersion=$(echo $vimLoc | sed -r 's/.+vim\.(.+)/\1/')
	echo "你系统VIM的版本为：$vimVersion"

	if [ $vimVersion = basic ]; then
		return 0
	else
		return 1
	fi
}

# vim基本配置以及vundle插件初始化
function configVimBasic() {
	if checkVimVersion; then
		echo "无需升级VIM"
	else
		echo "升级VIM"
		# 卸载vim-tiny版本
		sudo apt-get remove vim-tiny vim-commoin
		# 安装full版vim
		sudo apt-get install vim
	fi
	# 安装Git
	sudo apt-get install git
	# 判断vundle插件是否已经安装
	if [ -d ~/.vim/bundle/Vundle.vim ]; then
		echo "你已经安装了Vundle插件管理工具"
	else
		echo "安装Vundle插件管理工具"
		# 下载vundle插件
		git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	fi
	# 在$HOME目录下新建.vimrc配置文件
	#touch $HOME/.vimrc
	echo "配置用户的Vim配置文件.vimrc"
	# 将vim基本配置以及vundle插件的初始化代码插入到.vimrc
	cat ./vimBasicConf.txt > $HOME/.vimrc
}

# 安装，编译，配置自动补全插件YouCompleteMe
function configYouCompleteMe() {
	echo "安装自动补全插件YouCompleteMe"
	# 获取安装Github插件代码的结束位置，并在该位置之前插入安装
	# YouCompleteMe插件的代码
	sed -i "/^\" Github Plugin End/i\Plugin 'Valloric/YouCompleteMe'" $HOME/.vimrc
	# 在.vimrc文件尾部追加该插件的配置
	cat ./YouCompleteMe_conf.txt >> $HOME/.vimrc
	# vim上的自动补全插件，注意该插件需要手动编译！！！
	# 如果使用Vundle更新了YouCompleteMe，也需要重新编译！！！
	sudo apt-get install build-essential cmake
	sudo apt-get install python-dev python3-dev
}

# 在安装完YouCompleteMe之后编译并修改配置文件
function makeYouCompleteMe() {
	echo "编译自动补全插件YouCompleteMe"
	cd ~/.vim/bundle/YouCompleteMe
	./install.py --all
	echo "编译完成！"
	# 注释掉.ycm_extra_conf.py中的选项
	cp ./third_party/ycmd/cpp/ycm/.ycm_extra_conf.py ~/.ycm_extra_conf.py
	num=$(sed -n "/final_flags.remove/=" ~/.ycm_extra_conf.py)
	sed -i "$(expr $num - 1),$(expr $num + 2) s/^/#/" ~/.ycm_extra_conf.py
	# 添加库所在的flags
	num=$(sed -n "/^]/=" ~/.ycm_extra_conf.py)
	gcc_version=$(sed -r "s/.+gcc version ([0-9\.]+).+/\1/" /proc/version)
	sed -i "$num i# add by qiuyu\n'-isystem',\n'/usr/include',\n'-isystem',\n'/usr/include/x86_64-linux-gnu',\n'-isystem',\n'/usr/include/c++/$gcc_version',\n'-isystem',\n'/usr/include/c++/$gcc_version/backward',\n'-isystem',\n'/usr/include/x86_64-linux-gnu/c++/$gcc_version',\n'-isystem',\n'/usr/local/include'," ~/.ycm_extra_conf.py
	cd -
}

# 安装，配置语法检查插件syntastic
function configSyntastic() {
	echo "安装语法检查插件syntastic"
	# 获取安装Github插件代码的结束位置，并在该位置之前插入安装
	# syntastic插件的代码
	sed -i "/^\" Github Plugin End/i\Plugin 'vim-syntastic/syntastic'" $HOME/.vimrc
	# 在.vimrc文件尾部追加该插件的配置
	cat ./Syntastic_conf.txt >> $HOME/.vimrc
}

# 安装，配置代码折叠插件SimpylFold
function configSimpylFold() {
	echo "安装代码折叠插件SimpylFold"
	# 获取安装Github插件代码的结束位置，并在该位置之前插入安装
	# SimpylFold插件的代码
	sed -i "/^\" Github Plugin End/i\Plugin 'tmhedberg/SimpylFold'" $HOME/.vimrc
	# 在.vimrc文件尾部追加该插件的配置
	cat ./SimpylFold_conf.txt >> $HOME/.vimrc
}

# 安装，配置显示文件树/文件目录插件NERDTree
function configNERDTree() {
	echo "安装显示文件树/文件目录插件NERDTree"
	# 获取安装Github插件代码的结束位置，并在该位置之前插入安装
	# NERDTree插件的代码
	sed -i "/^\" Github Plugin End/i\Plugin 'scrooloose/nerdtree'" $HOME/.vimrc
	# 在.vimrc文件尾部追加该插件的配置
	cat ./NERDTree_conf.txt >> $HOME/.vimrc
}

# 安装，配置状态栏增强插件vim-airline
function configVimAirLine() {
	echo "安装状态栏增强插件vim-airline"
	# 获取安装Github插件代码的结束位置，并在该位置之前插入安装
	# vim-airline插件的代码
	sed -i "/^\" Github Plugin End/i\Plugin 'vim-airline/vim-airline'" $HOME/.vimrc
	sed -i "/^\" Github Plugin End/i\Plugin 'vim-airline/vim-airline-themes'" $HOME/.vimrc
	# 在.vimrc文件尾部追加该插件的配置
	cat ./AirLine_conf.txt >> $HOME/.vimrc
	# 需要安装相应打过powerline补丁的字体，不然在airline状态栏无法正常
	# 显示图标和三角形符号
	#git clone https://github.com/powerline/fonts.git --depth=1
	#cd fonts
	#./install.sh
    #mkdir -p ~/.config/fontconfig/conf.d
    #cp fontconfig/*.conf ~/.config/fontconfig/conf.d
	#cd ..
	#rm -rf fonts
	#fc-cache -vf 
	wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
	wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
    mkdir -p ~/.local/share/fonts
	mv PowerlineSymbols.otf ~/.local/share/fonts/ 
	fc-cache -vf ~/.local/share/fonts/
    mkdir -p ~/.config/fontconfig/conf.d
	mv 10-powerline-symbols.conf ~/.config/fontconfig/conf.d/
}

# 安装，配置查看显示代码文件中的宏，函数，变量定义等的插件taglist
function configTaglist() {
	echo "安装查看显示代码文件中的宏，函数，变量定义等的插件taglist"
	# 获取安装Github插件代码的结束位置，并在该位置之前插入安装
	# vim-scripts/taglist.vim插件的代码
	sed -i "/^\" Github Plugin End/i\Plugin 'vim-scripts/taglist.vim'" $HOME/.vimrc
	# 在.vimrc文件尾部追加该插件的配置
	cat ./Taglist_conf.txt >> $HOME/.vimrc 
	# 需要安装ctags插件
	sudo apt-get install exuberant-ctags 
}

# 定义存储插件名称以及对应配置安装函数的字典
declare -A plugin_dict
plugin_dict=(
    [YouCompleteMe]=configYouCompleteMe
	[Syntastic]=configSyntastic
	[SimpylFold]=configSimpylFold
	[NERDTree]=configNERDTree
	[AirLine]=configVimAirLine
	[Taglist]=configTaglist
)

configVimBasic 
# 命令行参数判断
echo "正在进行插件安装......"
ins_ycm=false
case $1 in
	-s) # 安装指定的插件
		for plugin in $@
		do 
			if [ $plugin == YouCompleteMe ]; then
				ins_ycm=true
			fi
			${plugin_dict[$plugin]}
		done
		;;
	-v) # 不安装指定的插件
		# 遍历plugin_dict所有的key
		for plugin_name in ${!plugin_dict[*]}
		do 
			if [ $plugin == YouCompleteMe ]; then
				ins_ycm=true
			fi
			canINS=true
			# 检查该key是否在命令行参数中
			for plugin in $@
			do 
				if [ $plugin_name == $plugin ]; then
					canINS=false
				fi
			done
			if $canINS; then
				${plugin_dict[$plugin_name]}
			fi
		done
		;;
    -all | *) # 全部安装
		ins_ycm=true
		# 遍历plugin_dict所有的value
		for plugin_install in ${plugin_dict[*]}
		do 
			$plugin_install
		done
		;;
esac
vim +PluginInstall +qall 
# 如果安装了自动补全插件YouCompleteMe，则编译该插件
if $ins_ycm; then
	makeYouCompleteMe
fi
echo "插件安装完成！"
echo "Enjoy..."
