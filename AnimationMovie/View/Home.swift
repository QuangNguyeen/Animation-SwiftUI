//
//  Home.swift
//  AnimationMovie
//
//  Created by nguyen.van.quangf on 01/04/2022.
//

import SwiftUI

struct Home: View {
    @Environment(\.colorScheme) var scheme
    
    // MARK: - Animated view properties
    @State var currentIndex = 0
    @State var currentTab = "Films"
    // MARK: - Environment values
    @Namespace var animation
    
    @State var detailMovie: Movie?
    @State var showDetailView = false
    @State var currentCardSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            // BG
            BGView()
            VStack {
                // custom nar var
                NavBar()
                
                SnapCarousel(spacing: 20, trailingSpace: 110, index: $currentIndex, items: movies) {
                    movie in
                    GeometryReader { proxy in
                        let size = proxy.size
                        
                        Image(movie.artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width, height: size.height)
                            .cornerRadius(15)
                            .matchedGeometryEffect(id: movie.id, in: animation)
                            .onTapGesture {
                                currentCardSize = size
                                detailMovie = movie
                                withAnimation(.easeInOut) {
                                    showDetailView = true
                                }
                            }
                    }
                }
                // since carousel is moved the current card a litter bit up
                // using padding to avoid the undercovering the top element
                .padding(.top, 150)
                
                CustomIndicator()
                
                HStack {
                    Text("Popular")
                        .font(.title3.bold())
                    
                    Spacer()
                    
                    Button("See more") {}
                    .font(.system(size: 16, weight: .semibold))
                }
                .padding()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(movies) { movie in
                            Image(movie.artwork)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 120)
                                .cornerRadius(15)
                        }
                    }
                    .padding()
                }
            }
            .overlay(content: {
                if let movie = detailMovie, showDetailView {
                    DetailView(movie: movie, showDetailView: $showDetailView, detailMovie: $detailMovie, currentCardSize: $currentCardSize, animation: animation)
                }
            })
        }
    }
    
    // MARK: - Custom Indicators
    @ViewBuilder
    func CustomIndicator() -> some View {
        HStack(spacing: 5) {
            ForEach (movies.indices, id: \.self) { index in
                Circle()
                    .fill(currentIndex == index ? .blue : .gray.opacity(0.5))
                    .frame(width: currentIndex == index ? 10 : 6, height: currentIndex == index ? 10 : 6)
            }
        }
        .animation(.easeInOut, value: currentIndex)
    }
    
    
    // MARK: - Custom nav bar
    @ViewBuilder
    func NavBar() -> some View {
        HStack(spacing: 0) {
            ForEach (["Films", "Localities"], id: \.self) { tab in
                Button {
                    withAnimation {
                        currentTab = tab
                    }
                } label: {
                    Text(tab)
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 20)
                        .background {
                            if currentTab == tab {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .environment(\.colorScheme, .dark)
                                    .matchedGeometryEffect(id: "TAB", in: animation)
                            }
                        }
                }

            }
        }
    }
    
    // MARK: - Blurred BG
    @ViewBuilder
    func BGView() -> some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            TabView(selection: $currentIndex) {
                ForEach(movies.indices, id: \.self) { index in
                    Image(movies[index].artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentIndex)
             
            let color: Color = (scheme == .dark ? .black : .white)
            // custom gradient
            LinearGradient(colors: [
                .black,
                .clear,
                color.opacity(0.15),
                color.opacity(0.5),
                color.opacity(0.8),
                color,
                color
            ], startPoint: .top, endPoint: .bottom)
            
            // Blurred overlay
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        .ignoresSafeArea()
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}
